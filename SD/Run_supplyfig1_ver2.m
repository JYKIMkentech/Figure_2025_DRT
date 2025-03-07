clc; clear; close all;

%% === 1) PREPARE DATA =========================================================
dataFolder = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';
dataFile   = 'AS1_4per_new.mat'; % Contains types A,B,C,D,E,F,G,H, etc.
load(fullfile(dataFolder, dataFile),'AS1_4per_new');
AS_data = AS1_4per_new;  % shorter name

% True gamma
trueFile = 'Gamma_unimodal.mat';
tmp_true = load(fullfile(dataFolder, trueFile));
theta_true = tmp_true.Gamma_unimodal.theta;  
gamma_true = tmp_true.Gamma_unimodal.gamma;

%% === 2) STYLING PARAMETERS ==================================================
lineWidthValue     = 1;    
fillAlpha          = 0.3;  
axisFontSize       = 8;   
legendFontSize     = 6;   
annotationFontSize = 9;    
legendTokenSize    = 3;

% Color palette
p_colors = [
    0.00000, 0.44706, 0.74118;  % Blue
    0.93725, 0.75294, 0.00000;  % Yellow
    0.80392, 0.32549, 0.29803;  % Red
    0.12549, 0.52157, 0.30588;  % Green
    % Add more if needed
];

% Subplot label strings (a,b,c... up to l)
subplotLabels = {'(a)','(b)','(c)','(d)','(e)','(f)', ...
                 '(g)','(h)','(i)','(j)','(k)','(l)'};

%% === 3) SCENARIOS & TYPE-GROUPS =============================================
scenarioList = [1, 5, 10]; % 3 scenarios

% We’ll define these “type groups” and their legend labels:
typeGroup_dt    = {'A','D','E','F'};  
legendLabels_dt = {'dt=0.1','dt=0.2','dt=1','dt=2'};

typeGroup_dur    = {'A','G','H'};   
legendLabels_dur = {'Dur=1000','Dur=500','Dur=250'};

typeGroup_N    = {'A','B','C'};  
legendLabels_N = {'N=201','N=101','N=21'};

%% === 4) MAKE A 3×4 FIGURE LAYOUT ============================================
figure('Name','CompareAll','Color','w','Units','centimeters',...
       'Position',[2 2 20 14]);  % Adjust size (width=20cm, height=14cm)

tiledlayout(3,4,'TileSpacing','compact','Padding','compact');

% We'll fill subplots left→right for each row:
% Row i (i=1..3) corresponds to scenarioList(i).
% Columns: 1=waveforms, 2=dt, 3=dur, 4=N

labelIdx = 1;  % to pick subplotLabels{labelIdx} in order

%% === 5) LOOP OVER ROWS (SCENARIOS) ==========================================
for iRow = 1:3
    sn = scenarioList(iRow);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (A) Column #1: Waveforms for this scenario (DUAL Y-AXIS)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax1 = nexttile;
    hold(ax1,'on'); box(ax1,'on');
    ax1.FontSize = axisFontSize;
    
    % -- Real data from AS1_4per_new(sn).t, .I, .V --
    tPlot = AS_data(sn).t;
    iPlot = AS_data(sn).I;  % Left axis
    vPlot = AS_data(sn).V;  % Right axis

    yyaxis left
    h1 = plot(tPlot, iPlot, 'Color',[0 0.5 0],'LineWidth',1,...
              'DisplayName','Current');
    ylabel('Current (A)','FontSize',axisFontSize);

    yyaxis right
    h2 = plot(tPlot, vPlot, 'Color',[1 0 0],'LineWidth',1,...
              'DisplayName','Voltage');
    ylabel('Voltage (V)','FontSize',axisFontSize);

    xlabel('Time (s)','FontSize',axisFontSize);
    title(sprintf('Waveform, Scenario=%d', sn),'FontSize',axisFontSize);

    % Create a single legend for both lines
    legend([h1,h2],{'Current','Voltage'}, ...
           'Location','best','FontSize',legendFontSize);

    text(0.02, 0.90, subplotLabels{labelIdx}, 'Units','normalized',...
         'FontSize',annotationFontSize,'FontWeight','bold');
    labelIdx = labelIdx + 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (B) Column #2: dt effect for this scenario
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax2 = nexttile;
    hold(ax2,'on'); box(ax2,'on');
    ax2.FontSize = axisFontSize;

    % Filter data for typeGroup_dt + scenario=sn
    matchIdx = false(size(AS_data));
    for k = 1:numel(AS_data)
        if ismember(AS_data(k).type, typeGroup_dt) && (AS_data(k).SN == sn)
            matchIdx(k) = true;
        end
    end
    selData = AS_data(matchIdx);
    
    addedType = false(1,numel(typeGroup_dt));
    for d = 1:numel(selData)
        tname       = selData(d).type;
        cidx        = find(strcmp(typeGroup_dt, tname));  
        theta_est   = selData(d).theta;
        gamma_avg   = selData(d).gamma_avg;
        gamma_lower = selData(d).gamma_lower;
        gamma_upper = selData(d).gamma_upper;

        % Shaded region for uncertainty
        fill([theta_est; flipud(theta_est)], ...
             [gamma_lower; flipud(gamma_upper)], ...
             p_colors(cidx,:), 'FaceAlpha',fillAlpha,'EdgeColor','none',...
             'HandleVisibility','off');
        
        % Average curve
        if ~addedType(cidx)
            plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
                 'Color',p_colors(cidx,:),...
                 'DisplayName',legendLabels_dt{cidx});
            addedType(cidx) = true;
        else
            plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
                 'Color',p_colors(cidx,:), 'HandleVisibility','off');
        end
    end
    % Dummy fill patch for UNC in legend
    fill(NaN,NaN,[0.5,0.5,0.5],'FaceAlpha',fillAlpha,'EdgeColor','none',...
         'DisplayName','UNC');
    
    % True curve
    plot(theta_true, gamma_true, 'k-','LineWidth',1,'DisplayName','True');
    
    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex',...
           'FontSize',axisFontSize);
    ylabel('$\gamma~(\Omega)$','Interpreter','latex','FontSize',axisFontSize);
    legend('Location','best','Box','off','FontSize',legendFontSize);
    
    text(0.02, 0.90, subplotLabels{labelIdx}, 'Units','normalized',...
         'FontSize',annotationFontSize,'FontWeight','bold');
    labelIdx = labelIdx + 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (C) Column #3: dur effect for this scenario
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax3 = nexttile;
    hold(ax3,'on'); box(ax3,'on');
    ax3.FontSize = axisFontSize;

    matchIdx = false(size(AS_data));
    for k = 1:numel(AS_data)
        if ismember(AS_data(k).type, typeGroup_dur) && (AS_data(k).SN == sn)
            matchIdx(k) = true;
        end
    end
    selData = AS_data(matchIdx);

    addedType = false(1,numel(typeGroup_dur));
    for d = 1:numel(selData)
        tname       = selData(d).type;
        cidx        = find(strcmp(typeGroup_dur, tname));
        theta_est   = selData(d).theta;
        gamma_avg   = selData(d).gamma_avg;
        gamma_lower = selData(d).gamma_lower;
        gamma_upper = selData(d).gamma_upper;

        fill([theta_est; flipud(theta_est)], ...
             [gamma_lower; flipud(gamma_upper)], ...
             p_colors(cidx,:), 'FaceAlpha',fillAlpha,'EdgeColor','none',...
             'HandleVisibility','off');
        
        if ~addedType(cidx)
            plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
                 'Color',p_colors(cidx,:),...
                 'DisplayName',legendLabels_dur{cidx});
            addedType(cidx) = true;
        else
            plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
                 'Color',p_colors(cidx,:), 'HandleVisibility','off');
        end
    end
    fill(NaN,NaN,[0.5,0.5,0.5],'FaceAlpha',fillAlpha,'EdgeColor','none',...
         'DisplayName','UNC');
    plot(theta_true, gamma_true, 'k-','LineWidth',1,'DisplayName','True');

    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex',...
           'FontSize',axisFontSize);
    ylabel('$\gamma~(\Omega)$','Interpreter','latex','FontSize',axisFontSize);
    legend('Location','best','Box','off','FontSize',legendFontSize);

    text(0.02, 0.90, subplotLabels{labelIdx}, 'Units','normalized',...
         'FontSize',annotationFontSize,'FontWeight','bold');
    labelIdx = labelIdx + 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (D) Column #4: N effect for this scenario
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax4 = nexttile;
    hold(ax4,'on'); box(ax4,'on');
    ax4.FontSize = axisFontSize;

    matchIdx = false(size(AS_data));
    for k = 1:numel(AS_data)
        if ismember(AS_data(k).type, typeGroup_N) && (AS_data(k).SN == sn)
            matchIdx(k) = true;
        end
    end
    selData = AS_data(matchIdx);

    addedType = false(1,numel(typeGroup_N));
    for d = 1:numel(selData)
        tname       = selData(d).type;
        cidx        = find(strcmp(typeGroup_N, tname));
        theta_est   = selData(d).theta;
        gamma_avg   = selData(d).gamma_avg;
        gamma_lower = selData(d).gamma_lower;
        gamma_upper = selData(d).gamma_upper;
        
        fill([theta_est; flipud(theta_est)], ...
             [gamma_lower; flipud(gamma_upper)], ...
             p_colors(cidx,:), 'FaceAlpha',fillAlpha,'EdgeColor','none',...
             'HandleVisibility','off');
        
        if ~addedType(cidx)
            plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
                 'Color', p_colors(cidx,:),...
                 'DisplayName',legendLabels_N{cidx});
            addedType(cidx) = true;
        else
            plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
                 'Color', p_colors(cidx,:), 'HandleVisibility','off');
        end
    end
    fill(NaN,NaN,[0.5,0.5,0.5],'FaceAlpha',fillAlpha,'EdgeColor','none',...
         'DisplayName','UNC');
    plot(theta_true, gamma_true, 'k-','LineWidth',1,'DisplayName','True');

    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex',...
           'FontSize',axisFontSize);
    ylabel('$\gamma~(\Omega)$','Interpreter','latex','FontSize',axisFontSize);
    legend('Location','best','Box','off','FontSize',legendFontSize);

    text(0.02, 0.90, subplotLabels{labelIdx}, 'Units','normalized',...
         'FontSize',annotationFontSize,'FontWeight','bold');
    labelIdx = labelIdx + 1;
end

%% === 6) OPTIONAL: SAVE THE FIGURE ============================================
exportgraphics(gcf,'CompareAll_3x4.png','Resolution',300);
