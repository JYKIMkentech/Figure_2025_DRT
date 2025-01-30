%% DRT_compare_effects_script.m
%  목적:
%   - 이미 계산/저장되어 있는 DRT 결과(.mat 파일)를 불러온 뒤,
%   - Effect of dt/dur/N을 보고자 하는 타입들을 선택(A, B, C, D, ...)하여
%   - 시나리오 1, 5, 10만 비교 플롯한다.

clc; clear; close all;

%% (1) 사용자 입력: 어떤 효과를 비교할 것인가?
disp('1) Effect of dt  => 비교군: A, D, E, F');
disp('2) Effect of dur => 비교군: A, G, H');
disp('3) Effect of N   => 비교군: A, B, C');
effectChoice = input('원하는 번호를 입력하세요(1~3): ');

switch effectChoice
    case 1
        effectName = 'dt';
        typeGroup  = {'A','D','E','F'};
    case 2
        effectName = 'dur';
        typeGroup  = {'A','G','H'};
    case 3
        effectName = 'N';
        typeGroup  = {'A','B','C'};
    otherwise
        error('입력값이 잘못되었습니다. 1~3 중 하나를 골라주세요.');
end

%% (2) 어떤 데이터셋(AS1_1per_new 등)을 불러올 것인지 선택
%  실제로는 4개 중 하나만 불러오거나, 여러 번 반복할 수도 있습니다.
%  예시로 "AS1_1per_new.mat"만 불러오도록 해봅니다.
dataFolder = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';
dataFile   = 'AS1_1per_new.mat';   % 여기서 원하는 파일명으로 바꿔주세요.
load(fullfile(dataFolder, dataFile),'AS1_1per_new');
AS_data = AS1_1per_new;  % 편의상

%% (3) 플롯할 시나리오 번호(예: 1,5,10) 설정
scenarioList = [1, 5, 10];

%% (4) figure 생성 (1 x 3 서브플롯 예시)
figure('Name',['Effect of ',effectName,' - ',dataFile], ...
       'NumberTitle','off','Color','w','Units','normalized',...
       'Position',[0.1 0.1 0.8 0.4]);

% 색상 몇 개 지정 (type마다 다른 색상)
cMap = lines(numel(typeGroup));

%% (5) 시나리오 반복
for i = 1:numel(scenarioList)
    subplot(1, numel(scenarioList), i);
    hold on;
    scenarioNum = scenarioList(i);

    % 해당 시나리오인 데이터들 중, type이 typeGroup에 속하는 항목만 골라 플롯
    % AS_data에는 여러 type(A,B,C...)과 시나리오(SN)가 섞여 있을 수 있습니다.
    %  -> (1) type이 typeGroup 중 하나인지 확인
    %  -> (2) SN == scenarioNum 인지 확인
    matchIdx = false(size(AS_data));  % 논리벡터
    for k = 1:numel(AS_data)
        isInGroup   = ismember(AS_data(k).type, typeGroup);
        isThisScn   = (AS_data(k).SN == scenarioNum);
        matchIdx(k) = isInGroup && isThisScn;
    end
    selData = AS_data(matchIdx);

    % selData에는 typeGroup 내 해당 시나리오의 결과들이 들어있음
    % 이제 각각 plot
    for d = 1:numel(selData)
        tname = selData(d).type;  % 예: 'A', 'D' 등
        % color index
        cidx  = find(strcmp(typeGroup,tname));  
        plotCol = cMap(cidx,:);

        % theta, gamma
        theta_est   = selData(d).theta;
        gamma_est   = selData(d).gamma_est;
        gamma_lower = selData(d).gamma_lower;
        gamma_upper = selData(d).gamma_upper;

        % 불확실성 구간 fill
        fill([theta_est; flipud(theta_est)], ...
             [gamma_lower; flipud(gamma_upper)], ...
             plotCol, 'FaceAlpha',0.2, 'EdgeColor','none');
        % 추정값 선
        plot(theta_est, gamma_est, 'LineWidth',1.5, ...
             'Color', plotCol, 'DisplayName',...
             [tname,'(SN=',num2str(scenarioNum),')']);
    end

    xlabel('\theta (ln(\tau))');
    ylabel('\gamma (Ohm)');
    title(['Scenario ', num2str(scenarioNum)]);
    legend('Location','best','Box','off');
    grid on; box on;
end

sgtitle(['Effect of ', effectName, ' - compare types: ', strjoin(typeGroup, ', ')]);

%% (6) (옵션) 그림 저장
% exportgraphics(gcf, ['Compare_',effectName,'_',dataFile,'.png'],'Resolution',300);
