%% ===================== plot_ocv_from_Data1.m =====================
% C/R/D step 분할 → 각 step 전하량 적분(Q, cumQ)
% SOC–OCV는 struct 형식 OCV.chg, OCV.dis (각각 nx2: [SOC, OCV])
% 첫 번째 그림: SOC–OCV (chg=data(4), dis=data(6))
% 두 번째 그림: 전압/전류 + step 경계, start/end 마커

clc; clear; close all;

%% 1) 엑셀의 Data_1 시트 읽기 (readtable만 사용)
xlsx_file = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\251001 FC_OCV_1_016_DC.xlsx';
T = readtable(xlsx_file, 'Sheet', 'Data_1', 'VariableNamingRule', 'preserve');

% 2) 필요한 열 추출 (2: 시험_시간(s), 7: 전류(A), 8: 전압(V))
t  = T{:, 2};   % 시험_시간(s)
I  = T{:, 7};   % 전류(A)
V  = T{:, 8};   % 전압(V)

% 기본 전처리
t = t(:); I = I(:); V = V(:);
valid = ~(isnan(t)|isnan(I)|isnan(V));
t = t(valid); I = I(valid); V = V(valid);
if any(diff(t) < 0)
    [t, ord] = sort(t); I = I(ord); V = V(ord);
end

%% 3) 전류 상태 구분
N = numel(t);
data1.t = t; data1.I = I; data1.V = V;
data1.type = char(zeros([N, 1]));
data1.type(I > 0)  = 'C';
data1.type(I == 0) = 'R';
data1.type(I < 0)  = 'D';

% step 인덱스
data1.step = zeros(N,1); m = 1; data1.step(1) = m;
for j = 2:N
    if data1.type(j) ~= data1.type(j-1), m = m + 1; end
    data1.step(j) = m;
end
vec_step = unique(data1.step); num_step = numel(vec_step);

% step별 구조체
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
    data(i_step).T        = zeros(size(range)); % 온도 없음
end

%% 4) step별 Q, cumQ (Ah)
for j = 1:num_step
    if numel(data(j).t) > 1
        data(j).Q    = abs(trapz(data(j).t, data(j).I)) / 3600;
        data(j).cumQ = abs(cumtrapz(data(j).t, data(j).I)) / 3600;
    else
        data(j).Q    = 0;
        data(j).cumQ = zeros(size(data(j).t));
    end
end

%% 5) OCV struct 생성 (nx2: [SOC, OCV])
OCV = struct();

% chg: data(4)에서 가져오기 (SOC 0->1)
if num_step >= 4 && data(4).Q > 0 && data(4).type == 'C'
    soc_chg = data(4).cumQ ./ data(4).Q;                   % 0~1
    soc_chg = min(max(soc_chg(:),0),1);
    ocv_chg = data(4).V(:);
    % SOC 기준 정렬(보기 좋게)
    [sOrd, idx] = sort(soc_chg);
    OCV.chg = [sOrd, ocv_chg(idx)];                        % nx2
else
    OCV.chg = zeros(0,2);
    warning('data(4)에서 Charge 구간을 찾지 못했습니다. (type=C, Q>0 필요)');
end

% dis: data(6)에서 가져오기 (SOC 1->0)
if num_step >= 6 && data(6).Q > 0 && data(6).type == 'D'
    soc_dis = 1 - (data(6).cumQ ./ data(6).Q);             % 1->0
    soc_dis = min(max(soc_dis(:),0),1);
    ocv_dis = data(6).V(:);
    [sOrd, idx] = sort(soc_dis);
    OCV.dis = [sOrd, ocv_dis(idx)];                        % nx2
else
    OCV.dis = zeros(0,2);
    warning('data(6)에서 Discharge 구간을 찾지 못했습니다. (type=D, Q>0 필요)');
end

% 작업공간에 저장 (클릭해 들어가면 SOC/OCV 두 열 확인 가능)
assignin('base','OCV',OCV);
assignin('base','data1',data1);
assignin('base','data_steps',data);

%% 6) 그림 1: SOC–OCV (chg=data(4), dis=data(6))
figure('Color','w'); hold on; grid on;
hasLegend = false;
if ~isempty(OCV.chg)
    plot(OCV.chg(:,1)*100, OCV.chg(:,2), '.', 'MarkerSize',8, ...
        'DisplayName','Charge (data4)'); hasLegend = true;
end
if ~isempty(OCV.dis)
    plot(OCV.dis(:,1)*100, OCV.dis(:,2), '.', 'MarkerSize',8, ...
        'DisplayName','Discharge (data6)'); hasLegend = true;
end
xlabel('SOC [%]'); ylabel('OCV [V]');
title('SOC–OCV from Data_1 (OCV.chg / OCV.dis)');
if hasLegend, legend('Location','best'); end

%% 7) 그림 2: 전압/전류 + step 경계, start/end 마커
figure('Color','w'); hold on;
yyaxis left
pV = plot(t, V, 'LineWidth', 1.4); grid on; ylabel('Voltage [V]');
yyaxis right
pI = plot(t, I, 'LineWidth', 1.2); ylabel('Current [A]');
xlabel('Time [s]');
title('Voltage & Current with Step Boundaries (C/R/D)');

% step 경계 수직선
change_idx = find([false; diff(double(data1.step))~=0]);
for k = 1:numel(change_idx)
    xline(t(change_idx(k)), '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
end
% 각 step 시작/끝 마커
for j = 1:num_step
    idxs = data(j).indx;
    plot(t(idxs(1)),  V(idxs(1)),  'o', 'MarkerSize', 6, 'MarkerFaceColor','b', 'MarkerEdgeColor','b'); % start
    plot(t(idxs(end)), V(idxs(end)), 'o', 'MarkerSize', 6, 'MarkerFaceColor','r', 'MarkerEdgeColor','r'); % end
end
legend([pV pI], {'Voltage','Current'}, 'Location','best');

% 타입 라벨(선택)
yl = ylim;
for j = 1:num_step
    idxs = data(j).indx;
    tx = t(idxs(round(end/2)));
    ty = yl(2) - 0.08*(yl(2)-yl(1));
    text(tx, ty, data(j).type, 'HorizontalAlignment','center', 'FontWeight','bold', 'Color',[0.3 0.3 0.3]);
end

%% 8) 요약 출력
fprintf('총 스텝 수: %d (C/R/D 전환 기준)\n', num_step);
nC = sum(arrayfun(@(s) s.type=='C', data));
nR = sum(arrayfun(@(s) s.type=='R', data));
nD = sum(arrayfun(@(s) s.type=='D', data));
fprintf('  Charge: %d, Rest: %d, Discharge: %d\n', nC, nR, nD);
for j = 1:num_step
    fprintf('Step %2d | Type=%s | N=%4d | Q=%.6f Ah\n', j, data(j).type, numel(data(j).t), data(j).Q);
end

save('G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\OCV_from_Data1.mat', 'OCV');

