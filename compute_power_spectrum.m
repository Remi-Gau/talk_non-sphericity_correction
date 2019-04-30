function gX = compute_power_spectrum(Y)
% compute normaliwed power spectrum of some data for each column
% assumes first dimension is time

for i_vox = 1:size(Y,2)
    temp = abs(fft(Y(:,i_vox))).^2;
    gX(i_vox,:) = temp./sum(temp);
end

end