clc;clear;close all;

%% 경로
file = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\데이터2.xlsx';
assert(exist(file,'file')==2, "파일을 찾을 수 없습니다: %s", file);

%% 1) 엑셀 읽기 (1행 헤더, 2행부터 숫자)
% 엑셀의 원래 열 순서: [time/s, Ewe/V, I/mA, Re(Z)/Ohm, -Im(Z)/Ohm]
raw = readmatrix(file, 'NumHeaderLines', 1);

% 혹시 공백열/NaN만 있는 꼬리 열이 있으면 제거
if size(raw,2) > 5
    raw = raw(:,1:5);
end
assert(size(raw,2) == 5, '엑셀에서 5개 열을 읽지 못했습니다.');

%% 2) 요구 포맷으로 재배열: [시간, 전류, 전압, Re(Z), -Im(Z)]
M = [raw(:,1), raw(:,3), raw(:,2), raw(:,4), raw(:,5)];   % nx5 행렬

% NaN이 있으면 0으로 채우고 싶다면 아래 주석 해제
% M = fillmissing(M,'constant',0);

%% 3) 간단 확인
fprintf('행 개수: %d, 열 개수: %d\n', size(M,1), size(M,2));   % nx5
% 변수 바로 꺼내쓰기
t = M(:,1);    % [s]
i = M(:,2);    % [mA]
v = M(:,3);    % [V]
rez   = M(:,4);  % [Ohm]
negim = M(:,5);  % [Ohm]

%% 4) 전류·전압 동시 플롯 (시간 공유, yyaxis)
figure('Color','w');
yyaxis left
plot(t, v, 'LineWidth', 1.2);
ylabel('Voltage [V]');
grid on;

yyaxis right
plot(t, i, 'LineWidth', 1.0);
ylabel('Current [mA]');

xlabel('Time [s]');
title('Voltage & Current vs Time');
grid on;

%% 5) Nyquist (옵션)
valid = ~isnan(rez) & ~isnan(negim);
if any(valid)
    figure('Color','w');
    plot(rez(valid), negim(valid), '.', 'MarkerSize', 6);
    axis equal; grid on;
    xlabel('Re(Z) [\Omega]'); ylabel('-Im(Z) [\Omega]');
    title('Nyquist Plot');
end

