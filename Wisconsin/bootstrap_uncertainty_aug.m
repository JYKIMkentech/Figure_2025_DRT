function [gamma_resample_all] = bootstrap_uncertainty_aug(t, ik, V_sd, lambda, n, dur, num_resamples)
% bootstrap_uncertainty_aug: 
%   - DRT 추정을 여러 번(bootstrap) 수행하여 gamma를 재추정
%   - 시간축/데이터를 복원추출 후 sort하여 SD_DRT_estimation_aug에 입력
%   - 최종적으로 (num_resamples x n) 형태의 gamma 재추정 결과를 반환
%
% Inputs:
%   t             - 시간 벡터
%   ik            - 전류 벡터
%   V_sd          - 전압(측정) 벡터
%   lambda        - 정칙화 파라미터
%   n             - RC 소자 개수(또는 discrete tau 개수)
%   dur           - tau_max (예: 1370)
%   num_resamples - 부트스트랩 반복 횟수(예: 500)
%
% Output:
%   gamma_resample_all - size = (num_resamples x n)
%
% Note: mean, prctile(5/95) 등은 이 함수를 호출한 후에 메인 스크립트에서 계산

    N = length(t);
    gamma_resample_all = zeros(num_resamples, n);

    for b = 1:num_resamples
        % (1) 복원추출
        resample_idx = randsample(N, N, true);  % N개를 복원추출

        % (2) 추출된 시간축/전류/전압
        t_resampled   = t(resample_idx);
        ik_resampled  = ik(resample_idx);
        Vsd_resampled = V_sd(resample_idx);

        % (3) 시간축이 뒤죽박죽 되지 않도록 unique + sort
        [t_unique, idx_u] = unique(t_resampled);
        ik_unique  = ik_resampled(idx_u);
        Vsd_unique = Vsd_resampled(idx_u);

        [t_sorted, idx_s] = sort(t_unique);
        ik_sorted  = ik_unique(idx_s);
        Vsd_sorted = Vsd_unique(idx_s);

        % (4) dt 재계산 (샘플 간 차분)
        dt_sorted = [t_sorted(1); diff(t_sorted)];

        % (5) DRT 추정
        [gamma_b, ~, ~, ~, ~, ~, ~] = SD_DRT_estimation_aug(...
            t_sorted, ik_sorted, Vsd_sorted, lambda, n, dt_sorted, dur);

        gamma_resample_all(b, :) = gamma_b(:)';
    end
end

