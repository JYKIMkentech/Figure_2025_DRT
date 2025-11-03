%% SOC–OCV Overlay (Raw: Golden vs Data1 DIS/CHG)
% 목적: 어떤 가공도 없이 그대로 겹쳐 보기 (정렬/보정/클리닝/스케일 변환 없음)
clc; clear; close all;

%% Paths
goldenPath = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\rOCV.mat';
data1Path  = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\OCV_from_Data1.mat';
outPath    = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\SOC_OCV_overlay_raw.png';

%% Load: Golden (두 형태 중 하나 가정)
load(goldenPath, 'OCV_golden', 'soc_values', 'ocv_values');
if exist('OCV_golden','var') && isfield(OCV_golden,'OCVdis')
    soc_g = double(OCV_golden.OCVdis(:,1));  ocv_g = double(OCV_golden.OCVdis(:,2));
else
    soc_g = double(soc_values(:));           ocv_g = double(ocv_values(:));
end

%% Load: Data1 (DIS/CHG)
S = load(data1Path, 'OCV'); OCV = S.OCV;
soc_dis = double(OCV.dis(:,1));  ocv_dis = double(OCV.dis(:,2));
soc_chg = double(OCV.chg(:,1));  ocv_chg = double(OCV.chg(:,2));

%% Plot (겹쳐 보기)
figure('Color','w'); hold on; grid on; box on; lw = 1.8;

% Golden: 선만(마커 없음)
p1 = plot(soc_g, ocv_g, '-', 'LineWidth', lw+0.4, 'Color', [0.10 0.10 0.10]); 

% Coin cell: DIS (선 + 간헐적 마커)
p2 = plot(soc_dis, ocv_dis, '.', 'LineWidth', lw, 'Color', [0.10 0.55 0.80]); 
set(p2, 'Marker','o','MarkerSize',3.5, ...
    'MarkerFaceColor',[0.10 0.55 0.80], 'MarkerEdgeColor','none', ...
    'MarkerIndices', 1:10:max(1,numel(soc_dis)));   % 10개 간격마다 점

% Coin cell: CHG (선 + 간헐적 마커)
p3 = plot(soc_chg, ocv_chg, '.', 'LineWidth', lw, 'Color', [0.80 0.10 0.55]);
set(p3, 'Marker','s','MarkerSize',3.5, ...
    'MarkerFaceColor',[0.80 0.10 0.55], 'MarkerEdgeColor','none', ...
    'MarkerIndices', 1:10:max(1,numel(soc_chg)));   % 10개 간격마다 점

xlabel('SOC'); ylabel('OCV [V]');
title('SOC–OCV Comparison');
legend([p1 p2 p3], {'rOCV Golden','Coin cell : DIS','Coin cell: CHG'}, 'Location','best');
set(gca,'FontName','Arial','LineWidth',1.0);


%% Save
exportgraphics(gcf, outPath, 'Resolution', 300);
fprintf('플롯 저장: %s\n', outPath);

