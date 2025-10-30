%% ===================== plot_ocv_from_Data1.m =====================
% 전류 부호 기준으로 C/R/D step 분할하고,
% 각 step별 전하량 적분(Q, cumQ) → 충전(step='C')에서 SOC–OCV 추출
% 그리고 원 데이터(전류/전압)와 step 경계를 함께 시각화

clc; clear; close all;

%% 1) 엑셀의 Data_1 시트 읽기 (readtable만 사용)
xlsx_file = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\251001 FC_OCV_1_016_DC.xlsx';
T = readtable(xlsx_file, 'Sheet', 'Data_1', 'VariableNamingRule', 'preserve');

% 2) 필요한 열 추출 (2: 시험_시간(s), 7: 전류(A), 8: 전압(V))
t  = T{:, 2};   % 시험_시간(s)
I  = T{:, 7};   % 전류(A)
V  = T{:, 8};   % 전압(V)

% 기본 전처리: 열 벡터 보장 및 NaN 제거(동일 인덱스 제거)
t = t(:); I = I(:); V = V(:);
valid = ~(isnan(t)|isnan(I)|isnan(V));
t = t(valid); I = I(valid); V = V(valid);

% 시간은 단조 증가 가정. 혹시 동일/역전이 있으면 정렬
if any(diff(t) < 0)
    [t, ord] = sort(t);
    I = I(ord); V = V(ord);
end

%% 3) 전류 상태 구분 (정확히 0을 휴지 R로 간주)
N = numel(t);
data1.t = t;
data1.I = I;
data1.V = V;

data1.type = char(zeros([N, 1]));
data1.type(data1.I > 0)  = 'C';  % Charge
data1.type(data1.I == 0) = 'R';  % Rest
data1.type(data1.I < 0)  = 'D';  % Discharge

% step 구분: 타입이 바뀔 때마다 step 증가
data1.step = zeros(N,1);
m = 1; data1.step(1) = m;
for j = 2:N
    if data1.type(j) ~= data1.type(j-1)
        m = m + 1;
    end
    data1.step(j) = m;
end
vec_step = unique(data1.step);
num_step = numel(vec_step);

% step별 구조체 구성
data_line = struct('V', [], 'I', [], 't', [], 'indx', [], 'type', 'R', ...
                   'steptime', [], 'T', [], 'Q', 0, 'cumQ', [], 'soc', []);
data = repmat(data_line, num_step, 1);

for i_step = 1:num_step
    range = find(data1.step == vec_step(i_step));
    data(i_step).V        = data1.V(range);
    data(i_step).I        = data1.I(range);
    data(i_step).t        = data1.t(range);
    data(i_step).indx     = range;
    data(i_step).type     = data1.type(range(1));
    data(i_step).steptime = data1.t(range);   % 절대시간 유지
    data(i_step).T        = zeros(size(range)); % 온도 데이터가 없으므로 0
end

%% 4) 각 step에서 전하량 적분 (Ah) 및 누적 전하(cumQ) 계산
for j = 1:num_step
    if numel(data(j).t) > 1
        % Ah 단위: trapz(초, 암페어) / 3600
        data(j).Q    = abs(trapz(data(j).t, data(j).I)) / 3600;
        data(j).cumQ = abs(cumtrapz(data(j).t, data(j).I)) / 3600;
    else
        data(j).Q    = 0;
        data(j).cumQ = zeros(size(data(j).t));
    end
end

%% 5) C와 D 스텝 모두에서 SOC–OCV 추출 (epsQ 쓰지 않음)
SOC = [];   % 0~1
OCV = [];

for j = 1:num_step
    if numel(data(j).cumQ) > 0 && data(j).Q > 0
        if data(j).type == 'C'
            soc_local = data(j).cumQ / data(j).Q;          % 0 -> 1
            data(j).soc = soc_local(:);
            SOC = [SOC; soc_local(:)];
            OCV = [OCV; data(j).V(:)];
        elseif data(j).type == 'D'
            soc_local = 1 - (data(j).cumQ / data(j).Q);    % 1 -> 0
            data(j).soc = soc_local(:);
            SOC = [SOC; soc_local(:)];
            OCV = [OCV; data(j).V(:)];
        else
            data(j).soc = nan(size(data(j).t));            % R
        end
        % 안전 범위 클램프
        if ~isempty(data(j).soc)
            data(j).soc = min(max(data(j).soc,0),1);
        end
    else
        data(j).soc = nan(size(data(j).t));
    end
end

% 정렬 (SOC 기준)
if ~isempty(SOC)
    [SOC, sOrd] = sort(min(max(SOC,0),1));
    OCV = OCV(sOrd);
end

SOC_OCV_Table = table(SOC, SOC*100, OCV, ...
    'VariableNames', {'SOC','SOC_pct','OCV'});
assignin('base','SOC_OCV_Table',SOC_OCV_Table);



%% 6) 시각화 1: 전압/전류와 step 경계, start/end 마커
figure('Color','w'); hold on;

yyaxis left
pV = plot(t, V, 'LineWidth', 1.4); grid on;
ylabel('Voltage [V]');

yyaxis right
pI = plot(t, I, 'LineWidth', 1.2);
ylabel('Current [A]');

xlabel('Time [s]');
title('Voltage & Current with Step Boundaries (C/R/D)');

% step 경계: 타입이 바뀌는 인덱스마다 수직선
change_idx = find([false; diff(double(data1.step))~=0]);
for k = 1:numel(change_idx)
    xline(t(change_idx(k)), '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
end

% 각 step의 시작/끝 마커 (start=파란 동그라미, end=빨간 동그라미)
hold on;
for j = 1:num_step
    idxs = data(j).indx;
    % 시작
    plot(t(idxs(1)), V(idxs(1)), 'o', 'MarkerSize', 6, 'MarkerFaceColor','b', 'MarkerEdgeColor','b');
    % 끝
    plot(t(idxs(end)), V(idxs(end)), 'o', 'MarkerSize', 6, 'MarkerFaceColor','r', 'MarkerEdgeColor','r');
end

% 범례
legend([pV pI], {'Voltage','Current'}, 'Location','best');

% 타입별 배경 색깔(선택): C/R/D 표시를 위해 텍스트 라벨
yl = ylim;
for j = 1:num_step
    idxs = data(j).indx;
    tx = t(idxs(round(end/2)));
    ty = yl(2) - 0.08*(yl(2)-yl(1));
    text(tx, ty, data(j).type, 'HorizontalAlignment','center', 'FontWeight','bold', 'Color',[0.3 0.3 0.3]);
end

%% 6-2) 시각화 2: SOC–OCV (방전만, data(6)만)
if num_step >= 6 && data(6).type == 'D' && data(6).Q > 0 ...
        && ~all(isnan(data(6).soc))
    SOC_d = min(max(data(6).soc(:),0),1);
    OCV_d = data(6).V(:);

    figure('Color','w');
    plot(SOC_d*100, OCV_d, '.', 'MarkerSize', 8); grid on;
    xlabel('SOC [%]');
    ylabel('OCV [V]');
    title('SOC–OCV (Discharge only, Step = data(6))');
else
    warning('data(6)이 방전 스텝이 아니거나, Q==0이거나, SOC가 비어 있습니다.');
end


%% 8) 결과 요약 출력
fprintf('총 스텝 수: %d (C/R/D 전환 기준)\n', num_step);
nC = sum(arrayfun(@(s) s.type=='C', data));
nR = sum(arrayfun(@(s) s.type=='R', data));
nD = sum(arrayfun(@(s) s.type=='D', data));
fprintf('  Charge: %d, Rest: %d, Discharge: %d\n', nC, nR, nD);

% 각 스텝별 전하량 요약
for j = 1:num_step
    fprintf('Step %2d | Type=%s | N=%4d | Q=%.6f Ah\n', j, data(j).type, numel(data(j).t), data(j).Q);
end

% 작업 공간에 결과도 보관
assignin('base','data1',data1);
assignin('base','data_steps',data);
