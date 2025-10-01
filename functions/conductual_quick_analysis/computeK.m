function [K, uniqueSetSizes] = computeK(stim)
% computeK_bySetSize - Calcula la capacidad de memoria visual (K) agrupada por tamaño del set
%
% Input:
%   stim.setSizes : matriz [120 x N] con los tamaños del set por ensayo
%   stim.accuracy : matriz [120 x N] con 1 = respuesta correcta, 0 = incorrecta
%   stim.change   : matriz [120 x N] con 1 = hubo cambio, 0 = no hubo cambio
%
% Output:
%   K               : vector con valores de K para cada tamaño de set único
%   uniqueSetSizes  : vector con los tamaños de set correspondientes a cada K

    % Aplanar todas las matrices en vectores
    setSize = stim.setSize(:);
    accuracy = stim.accuracy(:);
    change = stim.change(:);

    % Identificar los tamaños únicos de set
    uniqueSetSizes = unique(setSize);
    K = zeros(size(uniqueSetSizes));

    for i = 1:length(uniqueSetSizes)
        S = uniqueSetSizes(i);

        % Filtrar ensayos que tienen este set size
        idx = setSize == S;

        acc = accuracy(idx);
        chg = change(idx);

        % Tasa de aciertos
        H = mean(acc(chg == 1));

        % Tasa de falsas alarmas
        F = 1 - mean(acc(chg == 0));

        % Calcular K
        K(i) = S * (H - F);
    end
end

