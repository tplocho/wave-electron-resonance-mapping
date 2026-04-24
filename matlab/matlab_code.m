%% ===== INPUTS (geometry / profiles / models) ===== %%
a         = 2.1;        % minor radius [m]
R_0       = 6.2;        % major radius at axis [m]
ell       = 1;          % cyclotron harmonic index
Q_c       = 1;          % core q
Q_95      = 4;          % edge q

T_c_keV   = 10;         % core Te [keV]
T_e_keV   = 1;          % edge Te [keV]
n_c       = 1e20;       % core ne [m^-3]
n_e       = 1e19;       % separatrix/edge ne [m^-3]

mu_par    = 1.0;        % v_|| = mu_par * v_th

snap_frequencies_to_grid = false;    % quantize f to 0.1 GHz grid for reporting
verbose    = false;                  % extra prints
print_live = true;                   % live per-root table prints

%% ===== H-mode density profile params (for options 2 & 3) ===== %%

% (2) Exponential: n(r) = n_e + (n_c - n_e) * exp(-delta_exp * r/a)
delta_exp = 3.0;                 % e-fold length = a/delta_exp

% (3) Pedestal 
ped_frac = 0.80;                 % n_ped = n_e + ped_frac*(n_c - n_e), 0..1
r_ped    = 0.94*a;               % pedestal-top position [m]
delta_c  = 0.5;                  % mild core gradient
delta_p  = 10.0;                 % steep pedestal gradient

%% ===== CONSTANTS (CODATA) ===== %%
c        = 299792458;               % [m/s]
qe       = 1.602176634e-19;         % [C]
me       = 9.1093837015e-31;        % [kg]
eps0     = 8.8541878128e-12;        % [F/m]
kB       = 1.380649e-23;            % [J/K]
keV_to_K = 1.160451812e7;           % [K/keV]

%% ===== SCANS ===== %%
r_range        = 0:0.1:a;                  % [m]
theta_deg_rng  = 0:1:180;                  % [deg]
B_0_range      = 4.5:0.1:6.0;              % [T]
phi_deg_rng    = -20:1:20;                 % [deg]

% Frequency band limits 
BAND_LO_GHZ = 110;
BAND_HI_GHZ = 170;

% Base frequency grid (descending), exact 0.1 GHz step
base_f_GHz_grid = BAND_HI_GHZ:-0.1:BAND_LO_GHZ;   % [GHz]
base_w_grid     = base_f_GHz_grid*2*pi*1e9;
base_k_grid     = base_w_grid./c;

theta_rad_rng = deg2rad(theta_deg_rng);
phi_rad_rng   = deg2rad(phi_deg_rng);

%% ===== r-SELECTION: ASK THE USER ===== %%
fprintf(['\nSelect r-mode:\n' ...
         '  S  - Scan r over grid (exclude r=0)\n' ...
         '  A  - Fixed r = 0.95a m\n' ...
         '  B  - q(r) = 2      (compute exact r*, run only at r*)\n' ...
         '  C  - q(r) = 3/2    (compute exact r*, run only at r*)\n' ...
         '  F  - Fixed custom r (in the range of (0, a])\n' ...
         '  Q  - Lock to custom q_target (in the range of [1, 4])\n> ']);
mode_str = lower(strtrim(input('','s')));

switch mode_str
    case {'s','scan',''}
        r_it = r_range(r_range > 0);
        note = 'r scan';
    case {'2a','a'}
        r_fixed = 1.9;
        if r_fixed <= 0 || r_fixed > a, error('r_fixed must be in (0, a].'); end
        r_it = r_fixed;
        note = sprintf('Case 2a: r fixed = %.6f m', r_fixed);
    case {'2b','b'}
        q_target = 2.0;
        denom = (Q_95 - Q_c);
        frac  = (q_target - Q_c)/denom;
        if denom<=0 || frac<0 || frac>1, error('q_target out of bounds.'); end
        r_star = a*sqrt(frac);
        r_it = r_star;
        note = sprintf('Case 2b: q(r)=2 => r = %.6f m', r_star);
    case {'2c','c'}
        q_target = 1.5;
        denom = (Q_95 - Q_c);
        frac  = (q_target - Q_c)/denom;
        if denom<=0 || frac<0 || frac>1, error('q_target out of bounds.'); end
        r_star = a*sqrt(frac);
        r_it = r_star;
        note = sprintf('Case 2c: q(r)=3/2 => r = %.6f m', r_star);
    case {'f'}
        r_fixed = str2double(strtrim(input('Enter r_fixed [m]: ','s')));
        if ~isfinite(r_fixed) || r_fixed<=0 || r_fixed>a, error('r_fixed must be in (0, a].'); end
        r_it = r_fixed;
        note = sprintf('Custom fixed r = %.6f m', r_fixed);
    case {'q'}
        q_target = str2double(strtrim(input('Enter q_target: ','s')));
        if ~isfinite(q_target), error('Invalid q_target.'); end
        denom = (Q_95 - Q_c);
        frac  = (q_target - Q_c)/denom;
        if denom<=0 || frac<0 || frac>1
            error('q_target=%.6g lies outside [Q_c, Q_95]=[%.6g, %.6g].', q_target, Q_c, Q_95);
        end
        r_star = a*sqrt(frac);
        if r_star<=0 || r_star>a, error('Computed r* out of bounds.'); end
        r_it = r_star;
        note = sprintf('q-lock: q(r)=%.6g => r = %.6f m', q_target, r_star);
    otherwise
        error('Unknown selection "%s".', mode_str);
end
fprintf('r-selection: %s\n', note);

%% ===== DENSITY PROFILE SELECTION (ALL MODES) ===== %%
density_profile_id = select_density_profile_123();   % 1, 2, � 3
switch density_profile_id
    case 1, prof_name = 'parabolic';
    case 2, prof_name = 'exp';
    case 3, prof_name = 'ped';
end
fprintf('Density profile: %s\n', prof_name);

%% ===== OUTPUT CSV: FILENAME (DIRECT INPUT) ===== %%
filename = strtrim(input('\nEnter output CSV filename (e.g., DATASET.csv): ','s'));
if isempty(filename)
    filename = 'DATASET.csv';
end

if isfile(filename)
    ow = lower(strtrim(input(sprintf('File "%s" exists. Overwrite? (y/n): ', filename),'s')));
    if ismember(ow, {'y','yes'})
        delete(filename);
    else
        [~,n,e] = fileparts(filename);
        timestamp = datestr(now,'yyyymmdd_HHMMSS');
        if isempty(e), e = '.csv'; end
        filename = sprintf('%s_%s%s', n, timestamp, e);
        fprintf('Writing to new file: %s\n', filename);
    end
end
fprintf('Output file: %s\n', filename);

%% ===== CSV INITIALIZATION ===== %%
fid = fopen(filename,'w');
fprintf(fid, 'r (m),theta (deg),B0 (T),phi (deg),w/2pi (GHz),w/w,R (m),D_root\n');
fclose(fid);
fid = fopen(filename,'a');   % append mode

% Live console header (wider columns)
if print_live
    fprintf('\n%-9s %-12s %-8s %-12s %-15s %-14s %-10s %-12s\n', ...
        'r (m)','theta (deg)','B0 (T)','phi (deg)','f (GHz)','w/wc','R (m)','|D|');
    fprintf('%s\n', repmat('-',1,102));
end

%% ===== ROOT-FIND SETTINGS ===== %%
TolX   = 1e-9;                      % [rad/s]
TolFun = 1e-12;                     % residual tolerance for D(w)/w
opts   = optimset('TolX',TolX,'TolFun',TolFun,'Display','off');

epsN   = 1e-12;                     % guard above cutoff for N
batch_counter = 0;
root_count    = 0;

%% ===== MAIN LOOPS ===== %%
for r = r_it
    % q(r): Parabolic profile, ranging from q_c to q_95
    q_r = Q_c - (Q_c - Q_95)*(r^2/a^2);

    % n(r): according to cases 1/2/3
    switch density_profile_id
        case 1  % Parabolic 
            n_r = n_c - (n_c - n_e)*(r^2/a^2);

        case 2  % Exponential
            n_r = ne_Hmode_exp(r, a, n_c, n_e, delta_exp);

        case 3  % Pedestal 
            n_ped = n_e + ped_frac*(n_c - n_e);
            n_r   = ne_Hmode_pedestal(r, a, n_c, n_e, n_ped, r_ped, delta_c, delta_p);

        otherwise
            error('Invalid density_profile_id.');
    end

    % Temperature: Parabolic profile, ranging from T_c to T_e 
    T_r = (T_c_keV - (T_c_keV - T_e_keV)*(r^2/a^2))*keV_to_K;   % [K]

    % thermal & relativistic factors
    vth     = sqrt(3*kB*T_r/me);
    beta2   = (vth/c)^2;
    gamma   = 1/sqrt(1 - beta2);
    inv_gam = 1/gamma;
    v_par   = mu_par * vth;

    for theta = theta_rad_rng
        % Geometry
        R = sqrt(r^2 + R_0^2 + 2*r*R_0*cos(theta));

        for B_0 = B_0_range
            % B-field components & magnitude
            B_t = (B_0 * R_0)/R;
            B_p = (r * B_t)/(q_r * R);
            B   = hypot(B_t, B_p);

            omega_c = (qe * B)/me;
            omega_p = sqrt((qe^2 * n_r)/(me * eps0));
            A       = ell * omega_c * inv_gam;

            for phi = phi_rad_rng

                % Frequency grid, strict band
                w_grid = base_w_grid;  
                k_grid = base_k_grid;
                in_band = (w_grid >= BAND_LO_GHZ*2*pi*1e9) & (w_grid <= BAND_HI_GHZ*2*pi*1e9);
                w_grid = w_grid(in_band);
                k_grid = k_grid(in_band);
                
                if numel(w_grid) < 2
                    continue
                end

                % Vectorized D(w)/w on the band-limited grid
                mask_prop = (w_grid > (1+epsN)*omega_p);
                N = nan(size(w_grid));
                N(mask_prop) = sqrt(1 - (omega_p./w_grid(mask_prop)).^2);

                % k_parallel = k * N * sin(phi)
                k_par = k_grid .* N .* sin(phi);

                Bterm = k_par * v_par;
                Dn    = (w_grid - A - Bterm) ./ w_grid;  % normalized
                Dn(~mask_prop) = NaN;

                % Brackets where sign changes
                idx_sc = find_sign_changes(Dn);

                % Rare exact zeros
                iz = find(isfinite(Dn) & Dn==0);
                
                if ~isempty(iz), idx_sc = unique([idx_sc(:); max(iz(:)-1)]); end

                % Solve each bracket
                for u = idx_sc(:).'
                    w_lo = w_grid(u);   w_hi = w_grid(u+1);
                    fun = @(w) D_of_w(w, omega_c, inv_gam, v_par, phi, omega_p, c, ell, epsN);

                    Dwlo = fun(w_lo);  Dwhi = fun(w_hi);
                    
                    if ~isfinite(Dwlo) || ~isfinite(Dwhi) || Dwlo*Dwhi > 0
                        continue
                    end

                    [w_root, fval, flag] = fzero(fun, [w_lo, w_hi], opts);
                    
                    if flag <= 0 || ~isfinite(w_root)
                        continue
                    end

                    % GHz + hard band filter
                    f_GHz_root = w_root/(2*pi*1e9);

                    if snap_frequencies_to_grid
                        f_GHz_root = BAND_LO_GHZ + 0.1*round((f_GHz_root-BAND_LO_GHZ)/0.1);
                        w_root = f_GHz_root*2*pi*1e9;
                        fval   = fun(w_root);
                    end

                    if f_GHz_root < BAND_LO_GHZ || f_GHz_root > BAND_HI_GHZ
                        continue
                    end

                    root_count = root_count + 1;

                    % CSV append
                    fprintf(fid, '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.4e\n', ...
                        r, rad2deg(theta), B_0, rad2deg(phi), f_GHz_root, w_root/omega_c, R, fval);

                    % periodic hard flush: close & reopen
                    batch_counter = batch_counter + 1;
                    
                    if mod(batch_counter, 2000) == 0
                        fclose(fid);
                        fid = fopen(filename,'a');
                    end

                    % Live print
                    if print_live
                        fprintf('%-9.3f %-12.1f %-8.2f %-12.1f %-15.6f %-14.6f %-10.3f %-12.2e\n', ...
                            r, rad2deg(theta), B_0, rad2deg(phi), f_GHz_root, w_root/omega_c, R, abs(fval));
                    end
                end
            end
        end
    end
end

% final close
fclose(fid);
fprintf('\nTotal roots saved: %d\nFile: %s\n', root_count, filename);

%% ========== LOCAL FUNCTIONS ========== %%
function idx = find_sign_changes(D)
    idx = [];
    finite_mask = isfinite(D);
    
    if nnz(finite_mask) < 2
       return
    end
    
    valid_pair = finite_mask(1:end-1) & finite_mask(2:end);
    s1 = sign(D(1:end-1)); s2 = sign(D(2:end));
    sc = (s1.*s2) < 0 & valid_pair;
    idx = find(sc);
end

function Dn = D_of_w(w, omega_c, inv_gam, v_par, phi, omega_p, c, ell, epsN)

    if w <= (1+epsN)*omega_p
        Dn = NaN; return;  % evanescent region
    end
    
    N = sqrt(1 - (omega_p/w)^2);
    k = w / c;
    k_par = k * N * sin(phi);
    A = ell * omega_c * inv_gam;
    B = k_par * v_par;
    Dn = (w - A - B) / w;
end

% Density profile helpers 
function n_r = ne_Hmode_exp(r, a, n_c, n_e, delta)
    % (2) Exponential H-mode
    rho = r./a;
    n_r = n_e + (n_c - n_e) .* exp(-delta .* rho);
    
    if ~isfinite(n_r) || n_r <= 0
        n_r = max(n_e, eps);
    end
end

function n_r = ne_Hmode_pedestal(r, a, n_c, n_e, n_ped, r_ped, delta_c, delta_p)
    % (3) Pedestal H-mode
    rho  = r./a;
    rho0 = r_ped./a;
    rho0 = min(max(rho0, 0.85), 0.99);
    dc   = max(delta_c, 1e-8);
    dp   = max(delta_p, 1e-8);

    if rho <= rho0
        y   = rho / rho0;
        n_r = n_ped + (n_c - n_ped) * (exp(-dc*y) - exp(-dc)) / (1 - exp(-dc));
    else
        x   = (rho - rho0) / max(1 - rho0, eps);
        n_r = n_ped + (n_ped - n_e) / (1 - exp(-dp)) * (exp(-dp*x) - 1);
    end

    if ~isfinite(n_r) || n_r <= 0
        n_r = max(n_e, eps);
    end
end

function id = select_density_profile_123()
    fprintf(['\nSelect density profile:\n' ...
             '  1) par        (L-mode, parabolic profile)\n' ...
             '  2) exp        (H-mode, exponential profile)\n' ...
             '  3) ped        (H-mode, pedestal-type profile)\n> ']);
    val = str2double(strtrim(input('','s')));
    
    if isnan(val) || ~ismember(val,[1,2,3]), val = 1; end
    id = val;
end


