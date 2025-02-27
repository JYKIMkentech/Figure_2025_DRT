clear; clc; close all;

%% (1) 경로 설정
data_dir = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD';
output_dir = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_new';

% 8개의 특정 파일 목록 (1%,2%,3%,4%)
file_names = {
    'AS1_1per.mat', 'AS1_2per.mat', 'AS1_3per.mat', 'AS1_4per.mat',...
    'AS2_1per.mat', 'AS2_2per.mat', 'AS2_3per.mat', 'AS2_4per.mat'
};

%% (2) 파일 정보를 가져오기
mat_files = [];
for i = 1:length(file_names)
    file_path = fullfile(data_dir, file_names{i});
    if exist(file_path, 'file')
        mat_files = [mat_files; dir(file_path)];
    else
        fprintf('파일이 존재하지 않습니다: %s\n', file_path);
    end
end

%% (3) 파일별 처리
for fileIdx = 1:length(mat_files)
    % 파일 이름과 경로 설정
    data_file = fullfile(mat_files(fileIdx).folder, mat_files(fileIdx).name);
    [~, name, ~] = fileparts(data_file); % 예: 'AS2_1per' 등

    % (3-1) 데이터 로드
    loaded_struct = load(data_file);
    data = loaded_struct.(name);  % 구조체 필드를 이름으로 접근
    
    %% (3-2) 리샘플링을 위한 조합 정의
    %  - 1) dt=0.1, duration=1000, n=[201,101,21]
    %  - 2) dt=[0.2,1,2], duration=1000, n=201
    %  - 3) dt=0.1, duration=[500,250], n=201
    
    % 총 조합 수 계산
    num_combinations = 0;
    % 1) n=[201,101,21] → 3개
    num_combinations = num_combinations + 3;
    % 2) dt=[0.2,1,2] → 3개
    num_combinations = num_combinations + 3;
    % 3) duration=[500,250] → 2개
    num_combinations = num_combinations + 2;
    
    % combinations 구조체 배열 미리 할당
    combinations = struct( ...
        'dt', cell(1, num_combinations), ...
        'duration', cell(1, num_combinations), ...
        'n', cell(1, num_combinations), ...
        'type', cell(1, num_combinations));
    
    idx = 1;
    type_list = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    num_types = length(type_list);

    % ----- 조합 1 -----
    dt_fixed = 0.1;
    duration_fixed = 1000;
    n_list = [201, 101, 21];
    for iC = 1:length(n_list)
        combinations(idx).dt = dt_fixed;
        combinations(idx).duration = duration_fixed;
        combinations(idx).n = n_list(iC);
        combinations(idx).type = type_list(mod(idx-1, num_types) + 1);
        idx = idx + 1;
    end

    % ----- 조합 2 -----
    dt_list = [0.2, 1, 2];
    duration_fixed = 1000;
    n_fixed = 201;
    for iC = 1:length(dt_list)
        combinations(idx).dt = dt_list(iC);
        combinations(idx).duration = duration_fixed;
        combinations(idx).n = n_fixed;
        combinations(idx).type = type_list(mod(idx-1, num_types) + 1);
        idx = idx + 1;
    end

    % ----- 조합 3 -----
    dt_fixed = 0.1;
    duration_list = [500, 250];
    n_fixed = 201;
    for iC = 1:length(duration_list)
        combinations(idx).dt = dt_fixed;
        combinations(idx).duration = duration_list(iC);
        combinations(idx).n = n_fixed;
        combinations(idx).type = type_list(mod(idx-1, num_types) + 1);
        idx = idx + 1;
    end
    
    %% (3-3) 결과 구조체 초기화
    %  - ex) 'AS2_1per_new' 형태로 새로운 이름 생성
    new_data_name = [name '_new'];
    eval([new_data_name ' = struct(''dt'', [], ''dur'', [], ''n'', [], ''SN'', [], ''V'', [], ''I'', [], ''t'', [], ''type'', []);']);

    % 총 결과 행 개수 = (조합 개수) x (시나리오 10개)
    total_results = num_combinations * 10;
    
    index = 1;

    %% (3-4) 모든 조합에 대해 처리 (리샘플링)
    for iC = 1:length(combinations)
        dt_val = combinations(iC).dt;
        dur_val = combinations(iC).duration;
        n_val = combinations(iC).n;
        type_val = combinations(iC).type;

        for j = 1:10
            if isfield(data(j), 'SN') && ...
               isfield(data(j), 'V') && ...
               isfield(data(j), 'I') && ...
               isfield(data(j), 't')

                % (a) 원본 데이터 가져오기
                SN = data(j).SN;
                V_orig = data(j).V;
                I_orig = data(j).I;
                t_orig = data(j).t;

                % (b) duration 범위 내 추출
                dur_idx = (t_orig <= dur_val);
                V_dur = V_orig(dur_idx);
                I_dur = I_orig(dur_idx);
                t_dur = t_orig(dur_idx);

                % (c) dt에 따른 리샘플링
                %     가정: 원본이 dt=0.1초로 균일 → step = round(새 dt / 0.1)
                %     만약 원본 데이터가 다른 dt라면 적절한 보간(interp1) 등을 써야 함.
                step = round(dt_val / 0.1);
                if step < 1, step = 1; end  % 안전장치

                V_new = V_dur(1:step:end);
                I_new = I_dur(1:step:end);
                t_new = t_dur(1:step:end);

                % (d) 결과 구조체에 저장
                eval([new_data_name '(index).SN = SN;']);
                eval([new_data_name '(index).dt = dt_val;']);
                eval([new_data_name '(index).dur = dur_val;']);
                eval([new_data_name '(index).n = n_val;']);
                eval([new_data_name '(index).V = V_new;']);
                eval([new_data_name '(index).I = I_new;']);
                eval([new_data_name '(index).t = t_new;']);
                eval([new_data_name '(index).type = type_val;']);

                index = index + 1;
            else
                disp(['필드가 누락됨: ', mat_files(fileIdx).name, ', entry index: ', num2str(j)]);
            end
        end
    end

    %% (3-5) 새 파일 저장
    % 예: 'AS2_1per_new.mat'
    output_file = fullfile(output_dir, [name '_new.mat']);
    eval(['save(output_file, ''' new_data_name ''');']);
    
    disp(['파일 처리 완료: ', name]);
end
