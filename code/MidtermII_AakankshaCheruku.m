% Math105B — Midterm 02
% Area + Trigonometric Approximation + Least Squares (starter scaffold)

clear; clc; close all;

% Reconstruct or import the hand curve from Midterm I:
x = linspace(0, 2*pi, 400)';
y = 1.5 + 0.6*sin(x) + 0.2*sin(2*x);   % replace with your curve

% Area with two methods
area_trapz = trapz(x, y);
pp = spline(x, y);
f = @(t) ppval(pp, t);
area_spline = integral(f, min(x), max(x));

figure('Color','w'); hold on;
plot(x, y, 'g-', 'LineWidth', 1.5, 'DisplayName','my hand curve');

% Continuous trig polynomial S3(x)
Xc = [ones(size(x))/2, cos(x), sin(x), cos(2*x), sin(2*x), cos(3*x), sin(3*x)];
ac = Xc\y;
yc = Xc*ac;
plot(x, yc, 'b-', 'LineWidth', 1.2, 'DisplayName','continuous trigonometric method');

% 20 random sample points
rng(42);
idx = sort(randperm(numel(x), 20));
xs = x(idx); ys = y(idx);
plot(xs, ys, 'o', 'Color',[0.6 0.3 0], 'MarkerFaceColor',[0.6 0.3 0], 'DisplayName','20 random points');

% Linear least squares (no polyfit)
Xl = [xs, ones(size(xs))];
theta = (Xl.'*Xl)\(Xl.'*ys);
yl = theta(1)*x + theta(2);
plot(x, yl, 'r-', 'LineWidth', 1.2, 'DisplayName','least square method');

% Discrete trig polynomial T3(x) (no fft)
Xd = [ones(size(xs))/2, cos(xs), sin(xs), cos(2*xs), sin(2*xs), cos(3*xs)];
ad = (Xd.'*Xd)\(Xd.'*ys);
yd = [ones(size(x))/2, cos(x), sin(x), cos(2*x), sin(2*x), cos(3*x)]*ad;
plot(x, yd, 'Color',[0.5 0 0.5], 'LineWidth', 1.2, 'DisplayName','discrete trigonometric method');

legend('Location','best'); grid on; xlabel('x'); ylabel('y'); title('Midterm II Combined Plot');

% fprintf('Area (trapz): %.4f\nArea (spline): %.4f\n', area_trapz, area_spline);
