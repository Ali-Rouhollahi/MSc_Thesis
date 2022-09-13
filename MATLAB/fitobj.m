function y = fitobj(mat_addr)
coder.extrinsic('fit')
d_mat = zeros(1);
d_mat = load(mat_addr);
y = fit(d_mat.q,d_mat.tau_c,'linearinterp');
end
