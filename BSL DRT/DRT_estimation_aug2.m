function [gamma_est, R0_est, V_est, theta_discrete, W, y, OCV] = ...
    DRT_estimation_aug2(t, ik, V_sd, lambda_hat, n, dt, dur, SOC, soc_values, ocv_values)
% DRT_estimation_aug (방법 B)
% - 상수항/등식 제약 없이 첫 샘플에서 OCV(1)=V_sd(1)로 설정하여 y(1)=0 보장
% - 시작이 REST(I(1)≈0)일 때 V_est(1)=V_sd(1) 성립
%
% Inputs:
%   t, ik, V_sd, lambda_hat, n, dt, dur, SOC: 길이 N 벡터(또는 스칼라)들
%   soc_values, ocv_values: SOC–OCV 테이블 (SOC→OCV 보간용)
%
% Outputs:
%   gamma_est [n x 1], R0_est (scalar), V_est [N x 1],
%   theta_discrete [n x 1], W [N x n], y [N x 1], OCV [N x 1]

    % ---------- 0) 벡터 형식 정리 ----------
    t    = t(:);
    ik   = ik(:);
    V_sd = V_sd(:);
    dt   = dt(:);
    SOC  = SOC(:);
    N = numel(t);
    assert(all([numel(ik), numel(V_sd), numel(dt), numel(SOC)] == N), 'Input lengths must match');

    % ---------- 1) OCV 보간 ----------
    OCV = interp1(soc_values(:), ocv_values(:), SOC, 'linear', 'extrap');

    % ---------- 1-1) 방법 B: 첫 샘플 OCV를 V로 강제 ----------
    % 시작이 REST라는 실험 가정을 코드에 반영 (I(1)≈0일 때 V_est(1)=V_sd(1) 성립)
    OCV(1) = V_sd(1);

    % ---------- 2) tau/theta 격자 ----------
    tau_min = 0.1;           % 필요 시 조정
    tau_max = dur;           % 입력 dur = tau_max
    theta_discrete = linspace(log(tau_min), log(tau_max), n).';
    delta_theta    = theta_discrete(2) - theta_discrete(1);
    tau_discrete   = exp(theta_discrete);

    % ---------- 3) W 행렬 (i(k-1) 사용, 초기 RC=0 가정) ----------
    W = zeros(N, n);
    for k_idx = 2:N
        dtk = dt(k_idx);
        for i = 1:n
            a = exp(-dtk / tau_discrete(i));
            W(k_idx,i) = W(k_idx-1,i)*a + ik(k_idx-1)*(1 - a)*delta_theta;
        end
    end

    % ---------- 4) 설계행렬 (R0 포함, 상수항 없음) ----------
    W_aug = [W, ik];        % [N x (n+1)], params = [gamma; R0]

    % ---------- 5) 타겟 y = V - OCV ----------
    y = (V_sd - OCV);
    y = y(:);

    % ---------- 6) 정규화(γ에만, 1차 차분) ----------
    L = zeros(n-1, n);
    for i = 1:n-1
        L(i,i)   = -1;
        L(i,i+1) =  1;
    end
    L_aug = [L, zeros(n-1,1)];   % R0에는 정규화 X

    % ---------- 7) QP 목적식 ----------
    % minimize ||y - W_aug*params||^2 + λ||L_aug*params||^2
    H = 2*(W_aug.'*W_aug + lambda_hat*(L_aug.'*L_aug));
    f = -2*(W_aug.'*y);

    % ---------- 8) 부등식 제약: gamma>=0, R0>=0 ----------
    A_ineq = -eye(n+1);
    b_ineq = zeros(n+1,1);

    % ---------- 9) QP 해 ----------
    opts = optimoptions('quadprog','Display','off');
    params = quadprog(H, f, A_ineq, b_ineq, [], [], [], [], [], opts);

    % ---------- 10) 결과 ----------
    gamma_est = params(1:n);
    R0_est    = params(end);

    % ---------- 11) 전압 재구성 ----------
    V_est = OCV + W*gamma_est + ik*R0_est;
end
