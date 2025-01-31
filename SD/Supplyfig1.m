%% (0) 초기화 및 사용자 설정
clc; clear; close all;

% ----- 공통 스타일 파라미터 -----
lineWidthValue     = 1.5;  % 선 굵기
fillAlpha          = 0.3;  % 불확도 영역 투명도
axisFontSize       = 8;    % x, y축 라벨 및 tick 폰트 크기
legendFontSize     = 6;    % 범례 폰트 크기
annotationFontSize = 9;    % (a), (b), (c) 라벨 폰트 크기
legendTokenSize    = 4;    % 범례 아이콘(박스/선) 길이

% ----- Subplot Labels 및 위치 설정 -----
subplotLabels = {'(a)','(b)','(c)'}; 
labelPositions = [-0.25 1.05;
                  -0.25 1.05;
                  -0.25 1.05];

% ----- Figure 및 Subplot 레이아웃 설정 -----
figWidth  = 18;  
figHeight = 8;   

leftMargin   = 0.12;  
rightMargin  = 0.07;  
topMargin    = 0.08;  
bottomMargin = 0.15;
midGap       = 0.07;  

legendPosA = [0.25, 0.77, 0.10, 0.10];
legendPosB = [0.54, 0.77, 0.10, 0.10];
legendPosC = [0.84, 0.77, 0.10, 0.10];

% ----- 색상 팔레트 정의 -----
p_colors = [
    0.00000, 0.44706, 0.74118;  % Blue
    0.93725, 0.75294, 0.00000;  % Yellow
    0.80392, 0.32549, 0.29803;  % Red
    0.12549, 0.52157, 0.30588;  % Green
];

%% (1) 효과 선택
disp('1) Effect of dt  => compare group: A, D, E, F');
disp('2) Effect of dur => compare group: A, G, H');
disp('3) Effect of N   => compare group: A, B, C');
effectChoice = input('Enter a number (1~3): ');

switch effectChoice
    case 1
        effectName   = 'dt';
        typeGroup    = {'A','D','E','F'};  
        legendLabels = {'dt=0.1','dt=0.2','dt=1','dt=2'};  
    case 2
        effectName   = 'dur';
        typeGroup    = {'A','G','H'};
        legendLabels = {'Dur=1000','Dur=500','Dur=250'};  
    case 3
        effectName   = 'N';
        typeGroup    = {'A','B','C'};
        legendLabels = {'N=201','N=101','N=21'};          
    otherwise
        error('Invalid choice. Please choose 1, 2, or 3.');
end

%% (2) 데이터 로드
dataFolder = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';
dataFile   = 'AS1_1per_new.mat'; 
load(fullfile(dataFolder, dataFile),'AS1_1per_new');
AS_data = AS1_1per_new;  % 이 안에 type, SN, theta, gamma_est, ... 등이 있다고 가정

%% (2-1) 참값(Gamma_unimodal.mat) 로드
trueFile = 'Gamma_unimodal.mat';
tmp = load(fullfile(dataFolder, trueFile));  
% tmp.Gamma_unimodal 구조체 안에 theta, gamma가 있다고 가정
theta_true = tmp.Gamma_unimodal.theta;  % 201×1 double
gamma_true = tmp.Gamma_unimodal.gamma;  % 201×1 double

%% (3) 시나리오 리스트 (예: 1, 5, 10)
scenarioList = [1, 5, 10];
numScenarios = numel(scenarioList);

%% (4) Figure 생성
figure('Name',['Effect of ',effectName,' - ',dataFile], ...
       'NumberTitle','off','Color','w', ...
       'Units','centimeters','Position',[2 2 figWidth figHeight]);

subplotWidth  = (1 - leftMargin - rightMargin - (numScenarios-1)*midGap) / numScenarios;
subplotHeight = 1 - topMargin - bottomMargin;

%% (5) Subplot 순회하며 그래프
for i = 1:numScenarios
    leftPos = leftMargin + (i-1)*(subplotWidth + midGap);

    ax = subplot('Position',[leftPos, bottomMargin, subplotWidth, subplotHeight]);
    hold(ax,'on');
    ax.FontSize = axisFontSize;

    scenarioNum = scenarioList(i);

    % (5-1) 해당 시나리오 + 선택된 type에 해당하는 데이터만 필터
    matchIdx = false(size(AS_data));
    for k = 1:numel(AS_data)
        if ismember(AS_data(k).type, typeGroup) && (AS_data(k).SN == scenarioNum)
            matchIdx(k) = true;
        end
    end
    selData = AS_data(matchIdx);

    % (5-2) 타입별 추정치 및 불확도 구간 플롯
    for d = 1:numel(selData)
        tname       = selData(d).type;
        cidx        = find(strcmp(typeGroup, tname));  % 색깔 인덱스
        theta_est   = selData(d).theta;
        gamma_est   = selData(d).gamma_est;
        gamma_lower = selData(d).gamma_lower;
        gamma_upper = selData(d).gamma_upper;

        % 불확도 영역 (fill)
        fill([theta_est; flipud(theta_est)], ...
             [gamma_lower; flipud(gamma_upper)], ...
             p_colors(cidx,:), ...
             'FaceAlpha', fillAlpha, ...
             'EdgeColor','none', ...
             'HandleVisibility','off');

        % 추정 곡선 (legend 표시)
        plot(theta_est, gamma_est, ...
             'LineWidth', lineWidthValue, ...
             'Color', p_colors(cidx,:), ...
             'DisplayName', legendLabels{cidx});
    end

    % (5-3) 참값 곡선 (Gamma_unimodal) 플롯
    %      모든 subplot에서 동일한 참값을 그린다고 가정
    plot(theta_true, gamma_true, ...
         'k-', 'LineWidth', 1.8, ...
         'DisplayName', 'True'); 

    % (5-4) 축 레이블
    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex','FontSize',axisFontSize);
    ylabel('$\gamma~(\Omega)$','Interpreter','latex','FontSize',axisFontSize);
    box(ax,'on');

    % (5-5) 서브플롯 (a), (b), (c) 라벨
    text(ax, labelPositions(i,1), labelPositions(i,2), subplotLabels{i}, ...
        'Units','normalized', ...
        'FontSize', annotationFontSize, ...
        'FontWeight','bold');

    % (5-6) 범례
    hLeg = legend('Location','none','Box','off','FontSize',legendFontSize);
    set(hLeg, 'ItemTokenSize', [legendTokenSize, legendTokenSize]); 
    switch i
        case 1
            set(hLeg,'Position',legendPosA);
        case 2
            set(hLeg,'Position',legendPosB);
        case 3
            set(hLeg,'Position',legendPosC);
    end
end

%% (Optional) 그래프 파일로 저장
exportgraphics(gcf, ['Compare_',effectName,'_',dataFile,'.png'],'Resolution',300);

