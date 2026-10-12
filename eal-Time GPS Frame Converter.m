function GPSRealtime
clc; close all;

global WGS84_A WGS84_E2 MU REF_LATLON
WGS84_A    = 6378137.0;
WGS84_F    = 1/298.257223563;
WGS84_E2   = WGS84_F*(2-WGS84_F);
MU         = 3.986004418e14;
REF_LATLON = [28.6139, 77.2090];

C.latRange  = [-90,90];
C.lonRange  = [-180,180];
C.altRange  = [-500,1e6];
C.maxRadius = 1e9;

fprintf('\n==============================================================\n');
fprintf('   Real-Time GPS Frame Converter\n');
fprintf('   GPS -> ECI | ECEF | END | NEU\n');
fprintf('==============================================================\n');
fprintf('  Type GPS     : <lat> <lon> <alt>\n');
fprintf('  Simulate move: track <lat> <lon> <alt> <speed_m/s> <duration_s>\n');
fprintf('  Route        : route <lat1> <lon1> <lat2> <lon2> <alt>\n');
fprintf('  Commands     : origin | csv | clear | quit\n');
fprintf('--------------------------------------------------------------\n');

allStates = {};
trackLat  = [];
trackLon  = [];

while true
    userIn = strtrim(input('GPS >> ','s'));
    if isempty(userIn), continue; end

    parts = strsplit(userIn);
    cmd   = lower(parts{1});

    switch cmd
        case 'quit'
            break;

        case 'origin'
            if numel(parts) >= 3
                REF_LATLON = [str2double(parts{2}), str2double(parts{3})];
                fprintf('  [OK] Origin updated: lat=%.4f lon=%.4f\n', ...
                        REF_LATLON(1), REF_LATLON(2));
            end

        case 'csv'
            if ~isempty(allStates)
                writeCSV(allStates, 'gps_log.csv');
            else
                fprintf('  [CSV] No data yet.\n');
            end

        case 'clear'
            allStates = {};
            trackLat  = [];
            trackLon  = [];
            fprintf('  [OK] Cleared.\n');

        case 'track'
            if numel(parts) >= 6
                lat0 = str2double(parts{2});
                lon0 = str2double(parts{3});
                alt  = str2double(parts{4});
                spd  = str2double(parts{5});
                dur  = str2double(parts{6});
                [allStates, trackLat, trackLon] = runTrack( ...
                    lat0, lon0, alt, spd, dur, C, allStates, trackLat, trackLon);
            else
                fprintf('  Usage: track <lat> <lon> <alt> <speed_m/s> <duration_s>\n');
            end

        case 'route'
            if numel(parts) >= 6
                lat1 = str2double(parts{2}); lon1 = str2double(parts{3});
                lat2 = str2double(parts{4}); lon2 = str2double(parts{5});
                alt  = str2double(parts{6});
                [allStates, trackLat, trackLon] = runRoute( ...
                    lat1, lon1, lat2, lon2, alt, C, allStates, trackLat, trackLon);
            else
                fprintf('  Usage: route <lat1> <lon1> <lat2> <lon2> <alt_m>\n');
            end

        otherwise
            if numel(parts) >= 3
                lat = str2double(parts{1});
                lon = str2double(parts{2});
                alt = str2double(parts{3});
                if any(isnan([lat lon alt]))
                    fprintf('  [X] Invalid. Try: 28.6139 77.2090 216\n');
                    continue;
                end
                state = convertFrames('geodetic', [lat lon alt], C);
                allStates{end+1} = state; %#ok<AGROW>
                trackLat(end+1)  = lat;   %#ok<AGROW>
                trackLon(end+1)  = lon;   %#ok<AGROW>
                printState(state);
            else
                fprintf('  Usage: <lat> <lon> <alt>\n');
            end
    end
end

if ~isempty(allStates)
    writeCSV(allStates, 'gps_log.csv');
end
fprintf('\n  Session ended.\n');
end


function [allStates, trackLat, trackLon] = runTrack(lat0, lon0, alt, spd, dur, C, allStates, trackLat, trackLon)
fprintf('\n  [TRACK] %.4f, %.4f, %.0f m | speed=%.1f m/s dur=%.1f s\n', ...
        lat0, lon0, alt, spd, dur);
dt = 0.5;
t0 = tic;
step = 0;
while toc(t0) < dur
    step = step + 1;
    t    = toc(t0);
    distNorth = spd*t*cosd(45);
    distEast  = spd*t*sind(45);
    dLat = distNorth / 111320;
    dLon = distEast  / (111320*cosd(lat0));
    lat = lat0 + dLat;
    lon = lon0 + dLon;
    state = convertFrames('geodetic', [lat lon alt], C);
    allStates{end+1} = state; %#ok<AGROW>
    trackLat(end+1)  = lat;   %#ok<AGROW>
    trackLon(end+1)  = lon;   %#ok<AGROW>
    fprintf('  t=%5.1fs lat=%9.6f lon=%9.6f ECEF=(%11.1f,%11.1f,%11.1f)\n', ...
        t, lat, lon, state.ecef(1), state.ecef(2), state.ecef(3));
    pause(dt);
end
fprintf('  [TRACK] Finished - %d samples.\n\n', step);
end


function [allStates, trackLat, trackLon] = runRoute(lat1, lon1, lat2, lon2, alt, C, allStates, trackLat, trackLon)
fprintf('\n  [ROUTE] (%.4f,%.4f) -> (%.4f,%.4f) alt=%.0f m\n', ...
        lat1, lon1, lat2, lon2, alt);
N  = 60;
dt = 0.1;
for k = 0:N
    f   = k/N;
    lat = lat1 + f*(lat2-lat1);
    lon = lon1 + f*(lon2-lon1);
    state = convertFrames('geodetic', [lat lon alt], C);
    allStates{end+1} = state; %#ok<AGROW>
    trackLat(end+1)  = lat;   %#ok<AGROW>
    trackLon(end+1)  = lon;   %#ok<AGROW>
    fprintf('  step %2d/%d lat=%9.6f lon=%9.6f ECEF=(%11.1f,%11.1f,%11.1f)\n', ...
        k, N, lat, lon, state.ecef(1), state.ecef(2), state.ecef(3));
    pause(dt);
end
fprintf('  [ROUTE] Finished - %d samples.\n\n', N+1);
end


function state = convertFrames(inputType, inputVal, C)
global REF_LATLON
tNow  = now;
theta = gmstAngle(tNow);

lat=[]; lon=[]; alt=[]; eci=[]; ecef=[]; endv=[]; neuv=[];

switch lower(inputType)
    case 'geodetic'
        lat=inputVal(1); lon=inputVal(2); alt=inputVal(3);
        ecef = geodetic2ecef(lat,lon,alt);
    case 'ecef'
        ecef = inputVal(:);
        [lat,lon,alt] = ecef2geodetic(ecef);
    case 'eci'
        eci  = inputVal(:);
        ecef = eci2ecef(eci, theta);
        [lat,lon,alt] = ecef2geodetic(ecef);
    case 'end'
        lat=REF_LATLON(1); lon=REF_LATLON(2);
        ecef = end2ecef(inputVal(:), lat, lon);
        [~,~,alt] = ecef2geodetic(ecef);
    case 'neu'
        lat=REF_LATLON(1); lon=REF_LATLON(2);
        endv = neu2end(inputVal(:));
        ecef = end2ecef(endv, lat, lon);
        [~,~,alt] = ecef2geodetic(ecef);
    otherwise
        error('Unknown inputType: %s', inputType);
end

if isempty(eci),  eci  = ecef2eci(ecef, theta); end
if isempty(endv), endv = ecef2end(ecef, lat, lon); end
if isempty(neuv), neuv = end2neu(endv); end

validateConstraints(lat,lon,alt,ecef,eci,C);

state.timestamp = datenum2posix(tNow);
state.lat=lat; state.lon=lon; state.alt=alt;
state.eci=eci; state.ecef=ecef; state.end=endv; state.neu=neuv;
end


function ecef = geodetic2ecef(lat_deg, lon_deg, alt_m)
global WGS84_A WGS84_E2
lat=deg2rad(lat_deg); lon=deg2rad(lon_deg);
N = WGS84_A / sqrt(1 - WGS84_E2*sin(lat)^2);
x = (N+alt_m)*cos(lat)*cos(lon);
y = (N+alt_m)*cos(lat)*sin(lon);
z = (N*(1-WGS84_E2)+alt_m)*sin(lat);
ecef = [x;y;z];
end

function [lat_deg, lon_deg, alt_m] = ecef2geodetic(ecef)
global WGS84_A WGS84_E2
x=ecef(1); y=ecef(2); z=ecef(3);
lon = atan2(y,x);
p   = hypot(x,y);
lat = atan2(z, p*(1-WGS84_E2));
for k=1:6
    N   = WGS84_A / sqrt(1 - WGS84_E2*sin(lat)^2);
    alt = p/cos(lat) - N;
    lat = atan2(z, p*(1 - WGS84_E2*N/(N+alt)));
end
N   = WGS84_A / sqrt(1 - WGS84_E2*sin(lat)^2);
alt = p/cos(lat) - N;
lat_deg=rad2deg(lat); lon_deg=rad2deg(lon); alt_m=alt;
end

function theta = gmstAngle(datenumVal)
jd = datenumVal + 1721058.5;
T  = (jd - 2451545.0)/36525.0;
gmst_sec = 67310.54841 + (876600*3600 + 8640184.812866)*T ...
           + 0.093104*T^2 - 6.2e-6*T^3;
theta = deg2rad(mod(gmst_sec,86400)/240.0);
end

function r_ecef = eci2ecef(r_eci, theta)
c=cos(theta); s=sin(theta);
R=[c s 0; -s c 0; 0 0 1];
r_ecef = R * r_eci(:);
end

function r_eci = ecef2eci(r_ecef, theta)
c=cos(theta); s=sin(theta);
R=[c -s 0; s c 0; 0 0 1];
r_eci = R * r_ecef(:);
end

function r_end = ecef2end(r_ecef, lat_deg, lon_deg)
lat=deg2rad(lat_deg); lon=deg2rad(lon_deg);
R = [-sin(lon),           cos(lon),           0;
     -sin(lat)*cos(lon), -sin(lat)*sin(lon),  cos(lat);
     -cos(lat)*cos(lon), -cos(lat)*sin(lon), -sin(lat)];
r_end = R * r_ecef(:);
end

function r_ecef = end2ecef(r_end, lat_deg, lon_deg)
lat=deg2rad(lat_deg); lon=deg2rad(lon_deg);
R = [-sin(lon), -sin(lat)*cos(lon), -cos(lat)*cos(lon);
      cos(lon), -sin(lat)*sin(lon), -cos(lat)*sin(lon);
      0,         cos(lat),          -sin(lat)];
r_ecef = R * r_end(:);
end

function r_end = neu2end(r_neu)
r_end = [r_neu(2); r_neu(1); -r_neu(3)];
end

function r_neu = end2neu(r_end)
r_neu = [r_end(2); r_end(1); -r_end(3)];
end

function validateConstraints(lat, lon, alt, ecef, eci, C)
msgs = {};
if lat<C.latRange(1) || lat>C.latRange(2), msgs{end+1}=sprintf('Lat %.4f',lat); end
if lon<C.lonRange(1) || lon>C.lonRange(2), msgs{end+1}=sprintf('Lon %.4f',lon); end
if alt<C.altRange(1) || alt>C.altRange(2), msgs{end+1}=sprintf('Alt %.2f',alt); end
if norm(ecef)>C.maxRadius, msgs{end+1}='ECEF radius'; end
if norm(eci) >C.maxRadius, msgs{end+1}='ECI radius';  end
if ~isempty(msgs), warning('[Constraint] %s', strjoin(msgs,' | ')); end
end

function p = datenum2posix(dn)
p = (dn - datenum(1970,1,1,0,0,0)) * 86400;
end

function printState(s)
fprintf('\n  --- GPS INPUT ---\n');
fprintf('    lat=%12.7f  lon=%12.7f  alt=%10.2f m\n', s.lat, s.lon, s.alt);
fprintf('  --- ECEF [m] ---\n');
fprintf('    X=%15.3f  Y=%15.3f  Z=%15.3f\n', s.ecef);
fprintf('  --- ECI [m] ---\n');
fprintf('    X=%15.3f  Y=%15.3f  Z=%15.3f\n', s.eci);
fprintf('  --- END [m] ---\n');
fprintf('    E=%15.3f  N=%15.3f  D=%15.3f\n', s.end);
fprintf('  --- NEU [m] ---\n');
fprintf('    N=%15.3f  E=%15.3f  U=%15.3f\n', s.neu);
fprintf('  --- Range/Bearing ---\n');
fprintf('    Range=%10.2f m   Bearing=%7.2f deg\n', ...
        hypot(s.neu(1),s.neu(2)), mod(atan2d(s.neu(2),s.neu(1)),360));
fprintf('  --------------------------\n\n');
end

function writeCSV(states, fname)
fid = fopen(fname,'w');
fprintf(fid, ['timestamp,lat_deg,lon_deg,alt_m,' ...
              'ECI_x,ECI_y,ECI_z,ECEF_x,ECEF_y,ECEF_z,' ...
              'END_E,END_N,END_D,NEU_N,NEU_E,NEU_U\n']);
for i=1:numel(states)
    s = states{i};
    fprintf(fid, '%.6f,%.9f,%.9f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n', ...
        s.timestamp,s.lat,s.lon,s.alt,s.eci,s.ecef,s.end,s.neu);
end
fclose(fid);
fprintf('  [CSV] Saved %d rows -> %s\n', numel(states), fname);
end
