
% Math105B — Midterm 02 (MATLAB)
% Area + Trigonometric Approximation + Least Squares (No polyfit / No fft)
% Author: Aakanksha Cheruku
% Date: 2025-08-14
%
% Outputs saved to:
%   data/sample_points_20.csv
%   data/hand_curve_points.csv          (optional if loaded)
%   report/midterm2_combined.png
%   report/metrics.json

clear; clc; close all;

% ======= Input curve =======
% Preferred: load the same hand curve used in Midterm I
csv_path = fullfile('data','hand_curve_points.csv');
if exist(csv_path,'file')
    T = readtable(csv_path); x = T.x(:); y = T.y(:);
else
    % Fallback placeholder curve (replace with your data for grading)
    x = linspace(0, 2*pi, 400)';
    y = 1.5 + 0.6*sin(x) + 0.2*sin(2*x);
end

% ======= Area by two methods =======
area_trapz = trapz(x, y);
pp = spline(x, y);
f  = @(t) ppval(pp, t);
area_spline = integral(f, min(x), max(x));

% ======= Colors =======
c_green  = [0.00 0.60 0.00];
c_blue   = [0.00 0.45 0.74];
c_red    = [0.85 0.33 0.10];
c_purple = [0.49 0.18 0.56];
c_brown  = [0.60 0.30 0.00];

% ======= Ensure folders =======
if ~exist('data','dir'),   mkdir data;   end
if ~exist('report','dir'), mkdir report; end

% ======= Continuous trig polynomial (S3) =======
Xc = [ones(size(x))/2, cos(x), sin(x), cos(2*x), sin(2*x), cos(3*x), sin(3*x)];
ac = Xc \ y;
yc = Xc * ac;

% ======= 20 random sample points =======
rng(42);
idx = sort(randperm(numel(x), 20));
xs = x(idx); ys = y(idx);

% ======= Least squares line from 20 points (no polyfit) =======
Xl = [xs, ones(size(xs))];
theta = (Xl.'*Xl) \ (Xl.'*ys);
yl = theta(1)*x + theta(2);

% ======= Discrete trig polynomial (T3) from 20 points (no fft) =======
Xd = [ones(size(xs))/2, cos(xs), sin(xs), cos(2*xs), sin(2*xs), cos(3*xs)];
ad = (Xd.'*Xd) \ (Xd.'*ys);
yd = [ones(size(x))/2, cos(x), sin(x), cos(2*x), sin(2*x), cos(3*x)] * ad;

% ======= Plot (single combined figure) =======
figure('Color','w'); hold on;
plot(x, y, '-', 'Color', c_green,  'LineWidth', 1.5, 'DisplayName','my hand curve');
plot(x, yc,'-', 'Color', c_blue,   'LineWidth', 1.2, 'DisplayName','continuous trigonometric method');
plot(xs,ys,'o', 'Color', c_brown,  'MarkerFaceColor', c_brown, 'DisplayName','20 random points');
plot(x, yl,'-', 'Color', c_red,    'LineWidth', 1.2, 'DisplayName','least square method');
plot(x, yd,'-', 'Color', c_purple, 'LineWidth', 1.2, 'DisplayName','discrete trigonometric method');
legend('Location','best'); grid on;
xlabel('x'); ylabel('y'); title('Midterm II Combined Plot');

% ======= Save artifacts =======
% Save points
writetable(table(xs, ys, 'VariableNames', {'x','y'}), fullfile('data','sample_points_20.csv'));
% Save hand curve points if we didn't already load from CSV
if ~exist(csv_path,'file')
    writetable(table(x, y, 'VariableNames', {'x','y'}), fullfile('data','hand_curve_points.csv'));
end

% Save figure at 300 dpi
if exist('exportgraphics','file')
    exportgraphics(gcf, fullfile('report','midterm2_combined.png'), 'Resolution', 300);
else
    print(gcf, fullfile('report','midterm2_combined'), '-dpng', '-r300');
end

% Save metrics as JSON
results.area_trapz  = area_trapz;
results.area_spline = area_spline;
results.theta_ls    = struct('slope', theta(1), 'intercept', theta(2));
results.coef_S3     = ac(:)';
results.coef_T3     = ad(:)';
rmse = @(a,b) sqrt(mean((a-b).^2));
results.rmse_S3 = rmse(yc, y);
results.rmse_T3 = rmse(yd, y);
results.rmse_LS = rmse(yl, y);

fid = fopen(fullfile('report','metrics.json'),'w');
fwrite(fid, jsonencode(results), 'char'); fclose(fid);

disp('Saved: report/midterm2_combined.png, report/metrics.json, data/*.csv');
