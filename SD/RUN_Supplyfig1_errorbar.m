%% (0) 초기화 및 사용자 설정
clc; clear; close all;

% ----- 공통 스타일 파라미터 -----
lineWidthValue     = 1;    % 선 굵기
axisFontSize       = 8;    % x, y축 라벨 및 tick 폰트 크기
legendFontSize     = 6;    % 범례 폰트 크기
annotationFontSize = 9;    % (a), (b), (c) 라벨 폰트 크기
legendTokenSize    = 7;    % 범례 아이콘(박스/선) 길이

% ----- Subplot Labels 및 위치 설정 -----
subplotLabels = {'(a)','(b)','(c)'};
labelPositions = [-0.25 1.05;
                  -0.25 1.05;
                  -0.25 1.05];

% ----- Figure 및 Subplot 레이아웃 설정 -----
topMargin    = 0.10;
bottomMargin = 0.10;  
leftMargin   = 0.2;
rightMargin  = 0.2;
midGap       = 0.012;  % 서브플롯 사이 세로 간격

% (세로 3개 배치)
subplotWidthFrac  = 1 - leftMargin - rightMargin;
subplotHeightFrac = (1 - topMargin - bottomMargin - 2*midGap) / 3;

% 원하는 subplot 실제 높이/폭 비율
desiredRatio = 35/35;  % 원 코드 기준

figWidth = 9;  % cm
ratioTerm = desiredRatio * (subplotWidthFrac / subplotHeightFrac);
figHeight = ratioTerm * figWidth;

% ----- 범례 위치(예시) -----
legendPosA = [0.60, 0.80, 0.25, 0.10];
legendPosB = [0.60, 0.53, 0.25, 0.10];
legendPosC = [0.60, 0.26, 0.25, 0.10];

% ----- 색상 팔레트 정의 (MATLAB Default 유사) -----
p_colors = [
    0.00000, 0.44706, 0.74118;  % Blue
    0.93725, 0.75294, 0.00000;  % Yellow
    0.80392, 0.32549, 0.29803;  % Red
    0.12549, 0.52157, 0.30588;  % Green
    % 필요시 더 추가 가능
];

%% (1) 효과 선택
disp('1) Effect of dt  => compare group: A, D, E, F');
disp('2) Effect of dur => compare group: A, G, H');
disp('3) Effect of N   => compare group: A, B, C');
disp('4) Effect of error => compare group: A(1%) vs. A(5%)');
effectChoice = input('Enter a number (1~4): ');

%% (2) 데이터 로드 및 그룹 설정
dataFolder = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';

switch effectChoice
    case 1
        dataFile   = 'AS1_5per_new.mat';
        load(fullfile(dataFolder, dataFile),'AS1_5per_new');
        AS_data      = AS1_5per_new;  
        effectName   = 'dt';
        typeGroup    = {'A','D','E','F'};  
        legendLabels = {'dt=0.1','dt=0.2','dt=1','dt=2'};  

    case 2
        dataFile   = 'AS1_5per_new.mat';
        load(fullfile(dataFolder, dataFile),'AS1_5per_new');
        AS_data      = AS1_5per_new;
        effectName   = 'dur';
        typeGroup    = {'A','G','H'};
        legendLabels = {'Dur=1000','Dur=500','Dur=250'};  

    case 3
        dataFile   = 'AS1_5per_new.mat';
        load(fullfile(dataFolder, dataFile),'AS1_5per_new');
        AS_data      = AS1_5per_new;
        effectName   = 'N';
        typeGroup    = {'A','B','C'};
        legendLabels = {'N=201','N=101','N=21'};          

    case 4
        % (A) 1% 에러 데이터 불러오기
        dataFile_1per = 'AS1_1per_new.mat';
        tmp1 = load(fullfile(dataFolder, dataFile_1per), 'AS1_1per_new');
        AS_data_1per = tmp1.AS1_1per_new;

        % (B) 5% 에러 데이터 불러오기
        dataFile_5per = 'AS1_5per_new.mat';
        tmp2 = load(fullfile(dataFolder, dataFile_5per), 'AS1_5per_new');
        AS_data_5per = tmp2.AS1_5per_new;

        % (C) 두 데이터에서 Type='A'만 골라서, 이름을 'A_1per', 'A_5per'로 수정
        idxA_1per = strcmp({AS_data_1per.type}, 'A');
        idxA_5per = strcmp({AS_data_5per.type}, 'A');
        Adata_1per = AS_data_1per(idxA_1per);
        Adata_5per = AS_data_5per(idxA_5per);
        for iA = 1:numel(Adata_1per)
            Adata_1per(iA).type = 'A_1per';
        end
        for iA = 1:numel(Adata_5per)
            Adata_5per(iA).type = 'A_5per';
        end

        % (D) 구조체 배열로 합침
        AS_data = [Adata_1per, Adata_5per];

        % (E) 효과명, 그룹, 범례
        effectName   = 'error';
        typeGroup    = {'A_1per','A_5per'};
        legendLabels = {'A(1% error)','A(5% error)'};

    otherwise
        error('Invalid choice. Please choose 1, 2, 3, or 4.');
end

%% (2-1) 참값(Gamma_unimodal.mat) 로드
trueFile = 'Gamma_unimodal.mat';
tmp_true = load(fullfile(dataFolder, trueFile));
theta_true = tmp_true.Gamma_unimodal.theta;
gamma_true = tmp_true.Gamma_unimodal.gamma;

%% (3) 시나리오 리스트 (예: 1, 5, 10)
scenarioList = [1, 5, 10];
numScenarios = numel(scenarioList);

%% (4) Figure 생성
figure('Name',['Effect of ',effectName], ...
       'NumberTitle','off','Color','w', ...
       'Units','centimeters','Position',[2 2 figWidth figHeight]);

subplotWidth  = subplotWidthFrac;
subplotHeight = subplotHeightFrac;

%% (5) Subplot 순회하며 그래프 (직접 선+마커로 에러바 표현)
for i = 1:numScenarios
    bottomPos = bottomMargin + (numScenarios - i)*(subplotHeight + midGap);
    ax = subplot('Position',[leftMargin, bottomPos, subplotWidth, subplotHeight]);
    hold(ax,'on');
    ax.FontSize = axisFontSize;
    
    scenarioNum = scenarioList(i);
    
    % (5-1) 해당 시나리오 + 선택된 타입 필터링
    matchIdx = false(size(AS_data));
    for k = 1:numel(AS_data)
        if ismember(AS_data(k).type, typeGroup) && (AS_data(k).SN == scenarioNum)
            matchIdx(k) = true;
        end
    end
    selData = AS_data(matchIdx);
    
    % 이미 legend에 추가된 타입 체크 (한 타입당 한 번만 DisplayName 표시)
    addedType = false(1, numel(typeGroup));
    
    % 투명도 설정
    alphaVal = 0.3;  % 0.3 => 30% 불투명, 70% 투명
    
    for d = 1:numel(selData)
        tname       = selData(d).type;
        cidx        = find(strcmp(typeGroup, tname));   % 이 타입의 색상 인덱스
        theta_est   = selData(d).theta;
        gamma_avg   = selData(d).gamma_avg;
        gamma_lower = selData(d).gamma_lower;
        gamma_upper = selData(d).gamma_upper;
        
        % (각 포인트별 에러바 범위)
        err_lower = gamma_avg - gamma_lower;
        err_upper = gamma_upper - gamma_avg;
        
        plotColor = [p_colors(cidx,:), alphaVal];  % [R G B Alpha]

        % ========== [1] 마커(평균값) 먼저 플롯 ==========
        if ~addedType(cidx)
            % 첫 등장 타입이면 legend에 표시
            hMark = plot(theta_est, gamma_avg, 's', ...
                'LineStyle','none', ...
                'MarkerSize',   4, ...
                'MarkerEdgeColor', plotColor, ...
                'MarkerFaceColor', plotColor, ...
                'DisplayName',  legendLabels{cidx});
            addedType(cidx) = true;
        else
            % 이미 legend 등록된 타입이면 표시 안 함
            hMark = plot(theta_est, gamma_avg, 's', ...
                'LineStyle','none', ...
                'MarkerSize',   4, ...
                'MarkerEdgeColor', plotColor, ...
                'MarkerFaceColor', plotColor, ...
                'HandleVisibility','off');
        end

        % ========== [2] 에러바(수직선) 그리기 ==========
        % 실제로는 err_lower, err_upper를 써서 아래/위로 뻗어나가는 길이 계산
        gamma_lowVal  = gamma_avg - err_lower;  % == gamma_lower
        gamma_highVal = gamma_avg + err_upper;  % == gamma_upper

        % 점 개수만큼 for문으로 세로선 그려도 되고, 
        % 한번에 NaN으로 분리해서 그려도 되지만 여기서는 간단하게 for문
        for idxPoint = 1:length(theta_est)
            xVal = theta_est(idxPoint);
            yLow = gamma_lowVal(idxPoint);
            yHigh= gamma_highVal(idxPoint);
            
            % 수직선 플롯(캡은 생략)
            plot([xVal xVal], [yLow yHigh], '-', ...
                'Color', plotColor, ...
                'LineWidth', lineWidthValue, ...
                'HandleVisibility','off');  
        end
    end
    
    % (5-3) 참값 곡선 (True Curve) 플롯
    plot(theta_true, gamma_true, 'k-', 'LineWidth', 1, 'DisplayName', 'True'); 

    % (5-4) 축 레이블 설정
    ylabel('$\gamma~(\Omega)$','Interpreter','latex','FontSize',axisFontSize);
    if i == numScenarios
        xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex','FontSize',axisFontSize);
    else
        set(ax, 'XTickLabel',[]);
        xlabel(ax, '');
    end
    box(ax,'on');

    % (5-5) 서브플롯 라벨: (a), (b), (c)
    text(ax, labelPositions(i,1), labelPositions(i,2), subplotLabels{i}, ...
         'Units','normalized','FontSize', annotationFontSize, 'FontWeight','bold');

    % (5-6) 범례 생성 및 위치 지정
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

    % (5-7) X축 범위 고정(예: log(0.1) ~ log(1000))
    xlim([log(0.1), log(1000)]);
end

%% (Optional) 결과를 이미지 파일로 저장
exportgraphics(gcf, ['Compare_',effectName,'_manualbars.png'],'Resolution',300);

