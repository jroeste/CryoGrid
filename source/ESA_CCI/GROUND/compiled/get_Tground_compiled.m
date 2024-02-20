
function T = get_Tground_compiled(energy, c_thawed, c_frozen, E_frozen, T_end_freezing)

T = double(energy(5:end,:)>=0) .* energy(5:end,:) ./ c_thawed(2:end,:) + ...
    double(energy(5:end,:) <= E_frozen(2:end,:)) .* ((energy(5:end,:) - E_frozen(2:end,:)) ./ c_frozen(2:end,:) + T_end_freezing(2:end,:)) + ...
    double(energy(5:end,:) < 0 & energy(5:end,:) > E_frozen(2:end,:)) .* energy(5:end,:)./E_frozen(2:end,:) .*(T_end_freezing(2:end,:));
