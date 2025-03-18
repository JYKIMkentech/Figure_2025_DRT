%% ========================================================================
%  로컬 함수: 부트스트랩 (bootstrap_uncertainty_aug)
% ========================================================================
function gamma_resample_all = bootstrap_uncertainty_aug_Wisconsin(...
    t, ik, V_sd, lambda, n, dur, num_resamples, SOC_begin, Q_batt, soc_values, ocv_values)
%--------------------------------------------------------------------------
% bootstrap_uncertainty_aug:
%   부트스트랩(복원추출)을 통해 여러 번 DRT 추정을 수행하고,
%   각 시도에서 추정된 gamma를 모아 (num_resamples x n) 행렬로 반환합니다.
%
% Inputs:
%   t, ik, V_sd      : 원본 시계열 데이터
%   lambda           : 정칙화 파라미터
%   n                : RC 소자(또는 discrete tau) 개수
%   dur              : tau_max
%   num_resamples    : 부트스트랩 반복 횟수 (예: 500)
%   SOC_begin        : 해당 Trip의 SOC 시작값
%   Q_batt           : 배터리 용량 [Ah]
%   soc_values, ocv_values : SOC-OCV 데이터 (interp1에 사용)
%
% Output:
%   gamma_resample_all : (num_resamples x n) 행렬, 각 행은 한 번의 추정 결과
%--------------------------------------------------------------------------
    N = length(t);
    gamma_resample_all = zeros(num_resamples, n);

    for b = 1:num_resamples
        % (1) 복원추출
        resample_idx = randsample(N, N, true);
        
        % (2) 재샘플 데이터 추출
        t_resampled   = t(resample_idx);
        ik_resampled  = ik(resample_idx);
        Vsd_resampled = V_sd(resample_idx);
        
        % (3) 시간 축 unique + sort (1차원 벡터로 정렬)
        [t_unique, idxU] = unique(t_resampled);
        ik_unique  = ik_resampled(idxU);
        Vsd_unique = Vsd_resampled(idxU);
        
        [t_sorted, idxS] = sort(t_unique);
        ik_sorted  = ik_unique(idxS);
        Vsd_sorted = Vsd_unique(idxS);
        
        % (4) dt 재계산
        dt_sorted = [t_sorted(1); diff(t_sorted)];
        
        % (5) 부트스트랩 시, SOC 재계산
        SOC_sorted = SOC_begin + cumtrapz(t_sorted, ik_sorted)/(Q_batt*3600);
        
        % (6) DRT 추정 (사용자 정의 함수 호출)
        %    SOC, soc_values, ocv_values를 실제 값으로 전달하여 interp1 오류 방지
        [gamma_b, ~, ~, ~, ~, ~, ~] = DRT_estimation_aug(...
            t_sorted, ik_sorted, Vsd_sorted, lambda, n, dt_sorted, dur, ...
            SOC_sorted, soc_values, ocv_values);
        
        gamma_resample_all(b,:) = gamma_b(:)';
    end
end

