%% SOC–OCV Overlay (Raw Plot: Golden vs Data1 DIS/CHG)
clc; clear; close all;

% ===== Paths =====
goldenPath = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\rOCV.mat';
data1Path  = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\OCV_from_Data1.mat';

% ===== Options (최소 가공만; 정렬/보정/unique 없음) =====
doNormalizeSOC = true;   % 0–100 → 0–1 변환 (원하면 false)
doSaveFigure   = true;

% ===== Load: Golden =====
load(goldenPath, 'OCV_golden', 'soc_values', 'ocv_values');  % 둘 중 하나 사용
if exist('OCV_golden','var') && isfield(OCV_golden,'OCVdis')
    soc_g = double(OCV_golden.OCVdis(:,1));
    ocv_g = double(OCV_golden.OCVdis(:,2));
elseif exist('soc_values','var') && exist('ocv_values','var')
    soc_g = double(soc_values(:));
    ocv_g = double(ocv_values(:));
else
    error('SOC-OCV 데이터(soc_values/ocv_values 또는 OCV_golden.OCVdis)가 필요합니다.');
end

% ===== Load: Data1 OCV (DIS/CHG) =====
S = load(data1Path, 'OCV');
assert(isfield(S,'OCV'), 'OCV_from_Data1.mat에 OCV 구조체가 없습니다.');
OCV = S.OCV;

soc_dis = []; ocv_dis = [];
soc_chg = []; ocv_chg = [];
if isfield(OCV,'dis') && ~isempty(OCV.dis)
    soc_dis = double(OCV.dis(:,1));
    ocv_dis = double(OCV.dis(:,2));
end
if isfield(OCV,'chg') && ~isempty(OCV.chg)
    soc_chg = double(OCV.chg(:,1));
    ocv_chg = double(OCV.chg(:,2));
end

% ===== Minimal cleaning: NaN/Inf만 제거 (그 외 가공 없음) =====
valid_g   = isfinite(soc_g)   & isfinite(ocv_g);
soc_g     = soc_g(valid_g);   ocv_g   = ocv_g(valid_g);

if ~isempty(soc_dis)
    valid_dis = isfinite(soc_dis) & isfinite(ocv_dis);
    soc_dis   = soc_dis(valid_dis); ocv_dis = ocv_dis(valid_dis);
end
if ~isempty(soc_chg)
    valid_chg = isfinite(soc_chg) & isfinite(ocv_chg);
    soc_chg   = soc_chg(valid_chg); ocv_chg = ocv_chg(valid_chg);
end

% ===== (옵션) SOC 스케일 0–100 → 0–1 만 변환 =====
if doNormalizeSOC
    if ~isempty(soc_g)   && max(soc_g)   > 1.5, soc_g   = soc_g/100;   end
    if ~isempty(soc_dis) && max(soc_dis) > 1.5, soc_dis = soc_dis/100; end
    if ~isempty(soc_chg) && max(soc_chg) > 1.5, soc_chg = soc_chg/100; end
end

% ===== Plot (겹쳐 보기) =====
figure('Color','w'); hold on; grid on;
lw = 1.8;

p1 = plot(soc_g,   ocv_g,   '-',  'LineWidth', lw+0.4, 'Color', [0.1 0.1 0.1]);
p2 = []; p3 = [];
if ~isempty(soc_dis), p2 = plot(soc_dis, ocv_dis, '--', 'LineWidth', lw, 'Color', [0.10 0.55 0.80]); end
if ~isempty(soc_chg), p3 = plot(soc_chg, ocv_chg, '-.', 'LineWidth', lw, 'Color', [0.80 0.10 0.55]); end

xlabel('SOC'); ylabel('OCV [V]');
title('SOC–OCV comparsion');

legObjs = [p1, p2, p3];
legLabs = {'rOCV Golden'};
if ~isempty(p2), legLabs{end+1} = 'BSL data : DIS'; end
if ~isempty(p3), legLabs{end+1} = 'BSL data: CHG'; end
legend(legObjs(~cellfun(@isempty, num2cell(legObjs))), legLabs, 'Location', 'best');

% ===== Save =====
if doSaveFigure
    outPath = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\2025 DRT 최종본 논문\BSL DRT\SOC_OCV_overlay_raw.png';
    exportgraphics(gcf, outPath, 'Resolution', 300);
    fprintf('플롯 저장: %s\n', outPath);
end

