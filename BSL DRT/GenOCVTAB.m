%% ===================== plot_ocv_from_Data1_raw.m =====================
% 목적: "아주 raw" 상태 — 정렬/클리핑/스케일변환/평활화/보정 없음
% - 엑셀(Data_1)에서 시간/전류/전압 읽기
% - 전류 부호로 C/R/D 스텝 분할
% - 각 스텝에서 Q, cumQ 계산(trapz/cumtrapz)만 수행
% - OCV.chg(0->1), OCV.dis(1->0) 구성 (기록 순서 유지)
% - SOC–OCV는 선 + 마커로 표시해 굴곡이 보이도록
clc; clear; close all;

%% 1) 엑셀의 Data_1 시트 읽기 (readtable만 사용)
xlsx_file = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\251001 FC_OCV_1_016_DC.xlsx';
T = readtable(xlsx_file, 'Sheet', 'Data_1', 'VariableNamingRule', 'preserve');

% 필요한 열 추출 (2: 시험_시간(s), 7: 전류(A), 8: 전압(V)) — 어떤 가공도 안함
t = T{:, 2};   % 시험_시간(s)
I = T{:, 7};   % 전류(A)
V = T{:, 8};   % 전압(V)

t = t(:); I = I(:); V = V(:); % 형태만 세로로

%% 2) 전류 부호로 상태 구분(C/R/D), 스텝 인덱스 부여 (전처리/정렬 없음)
N = numel(t);
data1.t = t; data1.I = I; data1.V = V;
data1.type = repmat('R', [N, 1]);      % 기본 'R'
data1.type(I > 0)  = 'C';
data1.type(I < 0)  = 'D';

data1.step = zeros(N,1);
m = 1; data1.step(1) = m;
for j = 2:N
    if data1.type(j) ~= data1.type(j-1), m = m + 1; end
    data1.step(j) = m;
end
vec_step = unique(data1.step); num_step = numel(vec_step);

% 스텝 구조체
data_line = struct('V', [], 'I', [], 't', [], 'indx', [], 'type', 'R', ...
                   'steptime', [], 'T', [], 'Q', 0, 'cumQ', [], 'soc', []);
data = repmat(data_line, num_step, 1);

for i_step = 1:num_step
    range = find(data1.step == vec_step(i_step));
    data(i_step).V        = V(range);
    data(i_step).I        = I(range);
    data(i_step).t        = t(range);
    data(i_step).indx     = range;
    data(i_step).type     = data1.type(range(1));
    data(i_step).steptime = t(range);
    data(i_step).T        = zeros(size(range)); % 온도 미사용
end

%% 3) 스텝별 Q, cumQ (Ah) — trapz/cumtrapz만
for j = 1:num_step
    if numel(data(j).t) > 1
        data(j).Q    = abs(trapz(data(j).t, data(j).I)) / 3600;          % Ah
        data(j).cumQ = abs(cumtrapz(data(j).t, data(j).I)) / 3600;       % Ah
    else
        data(j).Q    = 0;
        data(j).cumQ = zeros(size(data(j).t));
    end
end

%% 4) OCV struct 생성 (정렬/클리핑 없음, 기록 순서 유지)  << 교체 버전
OCV = struct();

% chg: data(4) (SOC 0->1)
if num_step >= 4 && data(4).Q > 0 && data(4).type == 'C'
    soc_chg = data(4).cumQ ./ data(4).Q;   % 0 -> 1  (절댓값 누적 사용)
    ocv_chg = data(4).V;
    OCV.chg = [soc_chg(:), ocv_chg(:)];
else
    OCV.chg = zeros(0,2);
    warning('data(4) Charge 구간을 찾지 못했습니다. (type=C, Q>0 필요)');
end

% dis: data(6) (SOC 1->0)
if num_step >= 6 && data(6).Q > 0 && data(6).type == 'D'
    soc_dis = 1 - (data(6).cumQ ./ data(6).Q);   % 1 -> 0  (절댓값 누적 사용)
    ocv_dis = data(6).V;
    OCV.dis = [soc_dis(:), ocv_dis(:)];
else
    OCV.dis = zeros(0,2);
    warning('data(6) Discharge 구간을 찾지 못했습니다. (type=D, Q>0 필요)');
end

% 작업공간에 저장
assignin('base','OCV',OCV);
assignin('base','data1',data1);
assignin('base','data_steps',data);

%% 5) 그림 1: SOC–OCV (기록 순서 + 마커로 굴곡 가시화)
figure('Color','w'); hold on; grid on; box on;
hasLegend = false;
if ~isempty(OCV.chg)
    plot(OCV.chg(:,1)*100, OCV.chg(:,2), '-', 'LineWidth',1.0, ...
         'Color',[0.10 0.55 0.80], 'DisplayName','Charge (data4)');
    plot(OCV.chg(:,1)*100, OCV.chg(:,2), 'o', 'MarkerSize',3.5, ...
         'MarkerFaceColor',[0.10 0.55 0.80], 'MarkerEdgeColor','none', ...
         'HandleVisibility','off');
    hasLegend = true;
end
if ~isempty(OCV.dis)
    plot(OCV.dis(:,1)*100, OCV.dis(:,2), '-', 'LineWidth',1.0, ...
         'Color',[0.80 0.10 0.55], 'DisplayName','Discharge (data6)');
    plot(OCV.dis(:,1)*100, OCV.dis(:,2), 'o', 'MarkerSize',3.5, ...
         'MarkerFaceColor',[0.80 0.10 0.55], 'MarkerEdgeColor','none', ...
         'HandleVisibility','off');
    hasLegend = true;
end
xlabel('SOC [%]'); ylabel('OCV [V]');
title('SOC–OCV from Data_1 (Raw order, no sort/clip)');
if hasLegend, legend('Location','best'); end
set(gca,'FontName','Arial','LineWidth',1.0);

%% 6) 그림 2: 전압/전류 + step 경계 (마커/legend 없음, 전류 µA 스케일)
figure('Color','w'); hold on; box on;

% 왼쪽: 전압
yyaxis left
plot(t, V, '-', 'LineWidth', 1.4, 'HandleVisibility','off'); grid on
ylabel('Voltage [V]')

% 오른쪽: 전류 (µA)
yyaxis right
I_uA = I * 1e6;                       % 7e-5 A = 70 µA 등
plot(t, I_uA, '-', 'LineWidth', 1.2, 'HandleVisibility','off');
ylabel('Current [\muA]')
imx = max(1, max(abs(I_uA))); ylim([-1.2*imx, 1.2*imx])

xlabel('Time [s]')
title('OCV ')

% step 경계 수직선 (legend에 안 뜨도록)
change_idx = find([false; diff(double(data1.step))~=0]);
for k = 1:numel(change_idx)
    xline(t(change_idx(k)), '--', 'Color', [0.5 0.5 0.5], ...
          'LineWidth', 1, 'HandleVisibility','off');
end


%% 7) 요약 출력 + 저장
fprintf('총 스텝 수: %d (C/R/D 전환 기준)\n', num_step);
nC = sum(arrayfun(@(s) s.type=='C', data));
nR = sum(arrayfun(@(s) s.type=='R', data));
nD = sum(arrayfun(@(s) s.type=='D', data));
fprintf('  Charge: %d, Rest: %d, Discharge: %d\n', nC, nR, nD);
for j = 1:num_step
    fprintf('Step %2d | Type=%s | N=%4d | Q=%.6f Ah\n', j, data(j).type, numel(data(j).t), data(j).Q);
end

save('G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\OCV_from_Data1.mat', 'OCV');

