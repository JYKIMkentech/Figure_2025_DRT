%% ===================== plot_ocv_from_Data1.m =====================
clc; clear; close all;

% 1) 엑셀의 Data_1 시트 읽기 (readtable만 사용)
xlsx_file = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\251001 FC_OCV_1_016_DC.xlsx';
T = readtable(xlsx_file, 'Sheet', 'Data_1', 'VariableNamingRule', 'preserve');

% 2) 필요한 열 추출 (2: 시험_시간(s), 7: 전류(A), 8: 전압(V))
t  = T{:, 2};   % 시험_시간(s)
I  = T{:, 7};   % 전류(A)
V  = T{:, 8};   % 전압(V)


% 3) yyaxis 플롯
figure('Color','w');

yyaxis left
plot(t, V, 'LineWidth', 1.4);
ylabel('Voltage [V]');
grid on;

yyaxis right
plot(t, I, 'LineWidth', 1.2);
ylabel('Current [A]');

xlabel('Time [s]');
title('OCV vs time');
legend({'Voltage','Current'}, 'Location','best');
