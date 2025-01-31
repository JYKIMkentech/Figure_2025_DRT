%% figure_for_paper.m
clc; clear; close all;

%% (1) Figure 및 Subplot 배치 설정
figWidth  = 18;  % cm 단위 (가로)
figHeight = 12;  % cm 단위 (세로)

figure('Units','centimeters','Position',[3 3 figWidth figHeight]);

% 2행 × 3열 형태로 Subplot 배치: (a)~(f)
pos_a = [0.07 0.57 0.26 0.35];  % (a) Trip 1 전압 비교
pos_b = [0.41 0.57 0.26 0.35];  % (b) Trip 1 DRT
pos_c = [0.75 0.57 0.20 0.35];  % (c) Trip 1 SOC
pos_d = [0.07 0.10 0.26 0.35];  % (d) Trip 전체 전압 비교
pos_e = [0.41 0.10 0.26 0.35];  % (e) Trip 전체 3D DRT
pos_f = [0.75 0.10 0.20 0.35];  % (f) Trip 전체 SOC

%% (2) 데이터 불러오기
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\Wisconsin_DRT\udds_data_soc_results.mat', ...
     'udds_data_soc_results');
num_trips = length(udds_data_soc_results);

%% ================= (a) Trip 1 전압 비교 =========================
subplot('Position', pos_a);
trip_idx = 1;  % Trip 1
t       = udds_data_soc_results(trip_idx).t;
V_meas  = udds_data_soc_results(trip_idx).V;
V_drt   = udds_data_soc_results(trip_idx).V_est;  % DRT 추정 전압
I       = udds_data_soc_results(trip_idx).I;

yyaxis left
p1 = plot(t, V_meas, 'k-', 'LineWidth', 1.2, 'DisplayName', 'Measured V');
hold on;
p2 = plot(t, V_drt,  'r--','LineWidth', 1.2, 'DisplayName', 'Estimated V (DRT)');
ylabel('Voltage [V]');
%title('Trip 1 전압 비교');  % 주석처리

yyaxis right
p3 = plot(t, I, 'b-', 'LineWidth', 1.0, 'DisplayName', 'Current');
ylabel('Current [A]');
xlabel('Time [s]');

legend([p1 p2 p3],'Location','best');
set(gca, 'FontSize', 9);

% (a) 라벨
annotation('textbox',[pos_a(1) pos_a(2)+pos_a(4)*0.97 0.03 0.03], ...
           'String','(a)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% ================== (b) Trip 1 DRT ==============================
subplot('Position', pos_b);
theta_1 = udds_data_soc_results(trip_idx).theta_discrete;
gamma_1 = udds_data_soc_results(trip_idx).gamma_est;
R0_1    = udds_data_soc_results(trip_idx).R0_est;

plot(theta_1, gamma_1, 'm-', 'LineWidth', 1.5);
hold on;
xlabel('\theta = ln(\tau [s])');
ylabel('\gamma [\Omega]');
%title('Trip 1 DRT');  % 주석처리

% R0 값 텍스트로 표시
str_R0 = sprintf('R_0 = %.3e \\Omega', R0_1);
xrange = xlim; yrange = ylim;
text(xrange(1)+0.05*(xrange(2)-xrange(1)), ...
     yrange(2)-0.10*(yrange(2)-yrange(1)), ...
     str_R0, 'FontSize',9,'Interpreter','tex','Color','k');

set(gca, 'FontSize', 9);

% (b) 라벨
annotation('textbox',[pos_b(1) pos_b(2)+pos_b(4)*0.97 0.03 0.03], ...
           'String','(b)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% =========== (c) Trip 1 SOC 비교 (4개 모델) ====================
subplot('Position', pos_c);
CC_1   = udds_data_soc_results(trip_idx).CC_SOC;
SOC1RC = udds_data_soc_results(trip_idx).SOC_1RC;
SOC2RC = udds_data_soc_results(trip_idx).SOC_2RC;
SOCDRT = udds_data_soc_results(trip_idx).SOC_DRT;

p1c = plot(t, CC_1,   'k-', 'LineWidth',1.3, 'DisplayName','CC'); hold on;
p2c = plot(t, SOC1RC, 'b--','LineWidth',1.3, 'DisplayName','1RC');
p3c = plot(t, SOC2RC, 'r-.','LineWidth',1.3, 'DisplayName','2RC');
p4c = plot(t, SOCDRT, 'g-','LineWidth',1.3, 'DisplayName','DRT');
xlabel('Time [s]');
ylabel('SOC');
%title('Trip 1 SOC 비교');  % 주석처리
legend([p1c p2c p3c p4c], 'Location','best');
set(gca, 'FontSize', 9);

annotation('textbox',[pos_c(1) pos_c(2)+pos_c(4)*0.97 0.03 0.03], ...
           'String','(c)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% ========= (d) Trip 전체 전압 비교 (연속) ========================
subplot('Position', pos_d);
full_t   = [];
full_V   = [];
full_Vdrt= [];
full_I   = [];

for s = 1:num_trips-1
    full_t    = [full_t;    udds_data_soc_results(s).Time_duration];
    full_V    = [full_V;    udds_data_soc_results(s).V];
    full_Vdrt = [full_Vdrt; udds_data_soc_results(s).V_est];
    full_I    = [full_I;    udds_data_soc_results(s).I];
end

yyaxis left
p1d = plot(full_t, full_V, 'k-', 'LineWidth',1.0, 'DisplayName','Measured V');
hold on;
p2d = plot(full_t, full_Vdrt,'r--','LineWidth',1.0,'DisplayName','Estimated V (DRT)');
ylabel('Voltage [V]');
%title('Trip 전체 전압 비교');  % 주석처리

yyaxis right
p3d = plot(full_t, full_I, 'b-','LineWidth',0.8,'DisplayName','Current');
ylabel('Current [A]');
xlabel('Time [s]');

legend([p1d p2d p3d],'Location','best');
set(gca, 'FontSize', 9);

annotation('textbox',[pos_d(1) pos_d(2)+pos_d(4)*0.97 0.03 0.03], ...
           'String','(d)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% ============ (e) Trip 전체 3D DRT ==============================
subplot('Position', pos_e); 
hold on;

% Trip별 평균 SOC (DRT 기준) 사용 예시
soc_mid_all = zeros(num_trips,1);
for s = 1:num_trips-1
    soc_vals = udds_data_soc_results(s).SOC_DRT;
    soc_mid_all(s) = mean(soc_vals);
end

for s = 1:num_trips-1
    sox   = soc_mid_all(s);
    thvec = udds_data_soc_results(s).theta_discrete;
    gmvec = udds_data_soc_results(s).gamma_est;
    plot3(sox*ones(size(thvec)), thvec, gmvec, 'LineWidth',1.2);
end

xlabel('SOC');
ylabel('\theta = ln(\tau [s])');
zlabel('\gamma [\Omega]');
%title('Trip 전체 3D DRT');  % 주석처리
set(gca, 'FontSize', 9);
view(135, 30);

annotation('textbox',[pos_e(1) pos_e(2)+pos_e(4)*0.97 0.03 0.03], ...
           'String','(e)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% ========== (f) Trip 전체 SOC 비교 (4개 모델) ==================
subplot('Position', pos_f);
full_t2   = [];
full_cc   = [];
full_1rc  = [];
full_2rc  = [];
full_drt  = [];

for s = 1:num_trips-1
    full_t2  = [full_t2;  udds_data_soc_results(s).Time_duration];
    full_cc  = [full_cc;  udds_data_soc_results(s).CC_SOC];
    full_1rc = [full_1rc; udds_data_soc_results(s).SOC_1RC];
    full_2rc = [full_2rc; udds_data_soc_results(s).SOC_2RC];
    full_drt = [full_drt; udds_data_soc_results(s).SOC_DRT];
end

p1f = plot(full_t2, full_cc,  'k-','LineWidth',1.0,'DisplayName','CC'); hold on;
p2f = plot(full_t2, full_1rc, 'b--','LineWidth',1.0,'DisplayName','1RC');
p3f = plot(full_t2, full_2rc, 'r-.','LineWidth',1.0,'DisplayName','2RC');
p4f = plot(full_t2, full_drt, 'g-','LineWidth',1.0,'DisplayName','DRT');

xlabel('Time [s]');
ylabel('SOC');
%title('Trip 전체 SOC 비교');  % 주석처리
legend([p1f p2f p3f p4f],'Location','best');
set(gca, 'FontSize', 9);

annotation('textbox',[pos_f(1) pos_f(2)+pos_f(4)*0.97 0.03 0.03], ...
           'String','(f)','FontSize',10,'FontWeight','bold','LineStyle','none');


annotation('textbox',[pos_f(1) pos_f(2)+pos_f(4)*0.97 0.03 0.03],...
           'String','(f)','FontSize',10,'FontWeight','bold','LineStyle','none');
