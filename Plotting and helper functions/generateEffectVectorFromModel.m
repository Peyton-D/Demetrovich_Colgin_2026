function vec = generateEffectVectorFromModel(mdl, factorA, factorB, levelA, levelB)
% generateEffectVectorFromModel creates a fixed effect vector for a GLME model
% using effects coding, based on user-specified levels of two categorical factors.
%
% Inputs:
%   mdl     - a fitted GLME model object from fitglme
%   levelA  - string or char representing the level of Factor A
%   levelB  - string or char representing the level of Factor B
%
% Output:
%   vec     - 1xN vector matching the length of mdl.CoefficientNames

    % Get coefficient names
    coefNames = mdl.CoefficientNames;
    nCoef = length(coefNames);
    vec = zeros(1, nCoef);

    % Get levels for each factor
    levelsA = categories(mdl.Variables.(factorA));
    levelsB = categories(mdl.Variables.(factorB));

    % Validate input levels
    if ~ismember(levelA, levelsA)
        error('Invalid levelA. Must be one of: %s', strjoin(levelsA, ', '));
    end
    if ~ismember(levelB, levelsB)
        error('Invalid levelB. Must be one of: %s', strjoin(levelsB, ', '));
    end

    % Effects coding for Factor A
    Avec = effectsCoding(levelA, levelsA);

    % Effects coding for Factor B
    Bvec = effectsCoding(levelB, levelsB);

    % Fill in main effects
    for i = 1:length(levelsA)-1
        name = sprintf('%s_%s', factorA, levelsA{i});
        idx = find(strcmp(coefNames, name));
        if ~isempty(idx)
            vec(idx) = Avec(i);
        end
    end

    for i = 1:length(levelsB)-1
        nameB = sprintf('%s_%s', factorB, levelsB{i});
        idxB = find(strcmp(coefNames, nameB));
        if ~isempty(idxB)
            vec(idxB) = Bvec(i);
        end
    end

    % Fill in interaction terms
    for i = 1:length(levelsA) - 1
        for j=1:length(levelsB) - 1
            name = sprintf('%s_%s:%s_%s', factorA, levelsA{i}, factorB, levelsB{j});
            idx = find(strcmp(coefNames, name));
            if ~isempty(idx)
                vec(idx) = Avec(i) * Bvec(j);
            end
        end
    end

    % Add intercept
    interceptIdx = find(strcmp(coefNames, '(Intercept)'));
    if ~isempty(interceptIdx)
        vec(interceptIdx) = 1;
    end
end

function coded = effectsCoding(level, levels)
% Returns effects coding vector for a given level
    n = length(levels);
    coded = zeros(1, n-1);
    idx = find(strcmp(levels, level));
    if idx == n
        coded = -1 * ones(1, n-1);
    elseif idx <= n-1
        coded(idx) = 1;
    else
        error('Level not found in levels list.');
    end
end
