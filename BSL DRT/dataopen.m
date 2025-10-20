clc; clear; close all;

%% 경로
file = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\데이터2.xlsx';
assert(exist(file,'file')==2, "파일을 찾을 수 없습니다: %s", file);

%% 1) 엑셀 읽기 (1행 헤더, 2행부터 숫자)
% [time/s, Ewe/V, I/mA, Re(Z)/Ohm, -Im(Z)/Ohm]
T = readmatrix(file, 'NumHeaderLines', 1);

% ---- 원천 데이터: 전부 double 배열로만 유지 ----
t      = double(T(:,1));   % [s]
V      = double(T(:,2));   % [V]
I      = double(T(:,3));   % [mA]
ReZ    = double(T(:,4));   % [Ohm]
NegImZ = double(T(:,5));   % [Ohm]

% ---- Trip 전용 컨테이너: data1에는 Trip만 ----
data1 = struct('Trips_1',[],'Trips_2',[],'Trips_3',[], ...
               'Trips_4',[],'Trips_5',[],'Trips_6',[]);

%% 2) 전류=0 구간(50분 이상 연속) 탐지 -> 결과는 모두 double 배열
I_zero_tol = 1e-3;                  % 0 판정 허용오차 [mA]
min_zero_duration_sec = 50*60;      % 50분

zero_mask = abs(I) <= I_zero_tol;

d = diff([0; zero_mask; 0]);
start_idx_all = find(d == 1);
end_idx_all   = find(d == -1) - 1;

keep = false(size(start_idx_all));
for k = 1:numel(start_idx_all)
    s = start_idx_all(k); e = end_idx_all(k);
    keep(k) = (t(e) - t(s)) >= min_zero_duration_sec;
end
start_idx  = start_idx_all(keep);                % double
end_idx    = end_idx_all(keep);                  % double
start_time = t(start_idx);                       % double [s]
end_time   = t(end_idx);                         % double [s]
dur_sec    = end_time - start_time;              % double [s]

fprintf('Zero-runs (>=50min): %d개\n', numel(start_idx));

%% 3) 전류·전압 동시 플롯 + START/END 동그라미(파랑/빨강)
figure('Color','w');

yyaxis left
hV = plot(t, V, 'LineWidth', 1.2); hold on;
ylabel('Voltage [V]');
grid on;

yyaxis right
hI = plot(t, I, 'LineWidth', 1.0); hold on;
ylabel('Current [mA]');

% START: 파란 동그라미, END: 빨간 동그라미
hStart = plot(t(start_idx), I(start_idx), 'o', ...
    'MarkerSize', 6, 'LineWidth', 1.2, ...
    'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'none');

hEnd = plot(t(end_idx), I(end_idx), 'o', ...
    'MarkerSize', 6, 'LineWidth', 1.2, ...
    'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none');

xlabel('Time [s]');
title('Voltage & Current vs Time (Rest markers)');

% legend 핸들 명시적으로 지정
legend([hI, hStart, hEnd], {'Current','Rest START','Rest END'}, ...
       'Location','best');
grid on;

