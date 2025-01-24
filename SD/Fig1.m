clc; clear; close all;

%% (1) .fig 파일 두 개를 보이지 않게 열기
figA = openfig('Figure_Code1.fig','invisible');  % Current‐Voltage
figB = openfig('Figure_Code2.fig','invisible');  % DRT

%% (2) 각 Figure에서 축(Axes) 객체를 찾아오기
axA = findobj(figA, 'Type', 'axes');
axB = findobj(figB, 'Type', 'axes');

%% (3) 새 Figure 생성 (1×2로 나란히 배치)
newFig = figure('Name','MergedFigure',...
                'NumberTitle','off',...
                'Units','normalized',...
                'Position',[0.2 0.2 0.6 0.4]);

% (a) 왼쪽 subplot
subplot(1,2,1);
copyobj(axA, gca);  
title('(a) Current-Voltage','FontSize',12);

% (b) 오른쪽 subplot
subplot(1,2,2);
copyobj(axB, gca);
title('(b) DRT Estimation','FontSize',12);

%% (4) 최종 합쳐진 그림을 SVG 등으로 저장
saveas(newFig, 'Merged_Figure.svg');
