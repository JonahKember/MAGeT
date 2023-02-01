function pls(X,Y,params)
%%
%
% Inputs:
%   
%   X = [Feature x Observation]
%   Y = [Feature x Observation]
%   params = Parameter structure, including:
%       .n_perm = Number of permutations for hypothesis test (i.e., [1000]).
%       .p_val = Significance threshold (i.e., [.05]) 
%       .bs_thresh = Bootstrap-ratio threshold for defining significant features.
%       .save_path = Directory to save images.
%
% Output:
%
%   latent_variable_n = .png of loadings for each significant component.
%   null_distribution = .png of empirical covariance for each component against null distribution.
%   variance_covariance_X_Y = .png with variance in X and Y, and covariance in (X,Y), accounted for by LV
%
%%

% Define dimensions of data.
n_obs = size(X,1);
n_comp = size(X,2);

% Unpack parameters for cleaner code.
n_perm = params.n_perm;
p_val = params.p_val;
bs_thresh = params.bs_thresh;
save_path = params.save_path;

% Define function to measure covariance of two vectors.
covar = @(x,Y) sum((x - mean(x)).*(Y - mean(Y)))./length(x);

% Z-score
X_norm = zscore(X);
Y_norm = zscore(Y);

% Run PLS.
[x_weights,Y_weights,x_scores,Y_scores,~,pct_var] = plsregress(X_norm,Y_norm,n_comp);

% Calculate covariance of each component. 
covar_emp = covar(x_scores,Y_scores);

% Sort components bY covariance (matlab sorts bY variance in Y bY default).
[~,sorted_idx] = sort(covar_emp,'descend');
covar_emp = covar_emp(sorted_idx);

%% Plot variance in X and Y accounted for bY each component, as well as covariance of component scores.

fig = figure('Position',[515 403 884 421]);
hold on;plot(pct_var(1,sorted_idx),'LineWidth',2.5)
hold on;plot(pct_var(2,sorted_idx),'LineWidth',2.5)
hold on;plot(covar_emp,'LineWidth',2.5,'color','k')
xlim([1,n_comp])
Ylabel('Variance/Covariance')
xlabel('Component')
legend('var(X)','var(Y)','cov(X,Y)')
title('Variance/Covariance explained bY latent variables')
saveas(fig,[save_path,'variance_covariance_X_Y.png'])

%% Permutation testing

covar_null = zeros(n_comp,n_perm);

for null = 1:n_perm
    
    % RandomlY order X.
    sample_idx = randsample(1:n_obs,n_obs);
    X_null = X_norm(sample_idx,:);

    % Run PLS with randomlY ordered X.
    [~,~,x_scores_null,Y_scores_null] = plsregress(X_null,Y_norm,n_comp);

    % Calculate covariance of null-components.
    covar_null_unsorted = covar(x_scores_null,Y_scores_null);
    
    % Sort null-components bY covariance.
    [~,sorted_idx] = sort(covar_null_unsorted,'descend');
    covar_null(:,null) = covar_null_unsorted(sorted_idx);

end

% HYpothesis test.
sig_thresholds = quantile(covar_null',1 - p_val);
h_test = covar_emp >= sig_thresholds;

sig_components = find(h_test);

%% Plot empirical covariance for each component against the null distribution.

fig = figure('Position',[515 403 884 421]);
hold on;plot(1:n_comp,covar_null,'k')
hold on;plot(1:n_comp,covar_emp,'linewidth',2,'color','blue')
hold on;plot(1:n_comp,sig_thresholds,'--','linewidth',2,'color','red')
xlim([1,n_comp])
xlabel('Component')
Ylabel('Covariance')
legend(['Permutation X',repelem({''},n_perm - 1),'Empirical X',['Threshold {\it p} < ',num2str(p_val)]])
title('Null Distribution')
saveas(fig,[save_path,'null_distribution.png'])

%% For anY significant components, run bootstrapp resampling and plot.

for n_sig_comp = 1:length(sig_components)

    % Set component.
    sig_comp = sig_components(n_sig_comp);

    %% Bootstrapping.

    bs_weights_x = zeros(n_comp,n_bootstraps);
    bs_weights_Y = zeros(size(Y,2),n_bootstraps);
    
    for bs = 1:n_bootstraps
    
        % Resample with replacement.
        sample_idx = datasample(1:n_obs,n_obs);
        
        % Z-score
        X_norm = zscore(X(sample_idx,:));
        Y_norm = zscore(Y(sample_idx,:));
        
        % Run PLS.
        [x_weights_bs,Y_weights_bs] = plsregress(X_norm,Y_norm,n_comp);
        
        % Find matching component.
        similaritY_x = corr(x_weights(:, sig_comp),x_weights_bs);
        similaritY_Y = corr(Y_weights(:, sig_comp),Y_weights_bs);
    
        match_x = find(abs(similaritY_x) == max(abs(similaritY_x)));
        match_Y = find(abs(similaritY_Y) == max(abs(similaritY_Y)));
        
        % Ensure weights are in same direction.
        if similaritY_x(match_x) < 0
            x_weights_bs = -x_weights_bs;
        end
        if similaritY_Y(match_Y) < 0
            Y_weights_bs = -Y_weights_bs;
        end
    
        % Track weights.
        bs_weights_x(:,bs) = x_weights_bs(:,match_x);
        bs_weights_Y(:,bs) = Y_weights_bs(:,match_Y);
    
    end
    
    % Calculate error and bootstrap ratio.
    x_se = std(bs_weights_x,[],2);
    x_bs_ratio = x_weights(:,sig_comp)./x_se;
    
    Y_se = std(bs_weights_Y,[],2);
    Y_bs_ratio = Y_weights(:,sig_comp)./Y_se;
    
    %% Find significant variables (i.e., |Bootstrap-ratio| greater than threshold).
    
    % Find variables in X that load on to the component.
    x_sig = zeros(n_comp,1);
    x_nonsig = zeros(n_comp,1);
    
    x_sig_idx = abs(x_bs_ratio) > bs_thresh;
    x_nonsig_idx = abs(x_bs_ratio) <= bs_thresh;
    
    x_sig(x_sig_idx) = x_weights(x_sig_idx,sig_comp);
    x_nonsig(x_nonsig_idx) = x_weights(x_nonsig_idx,sig_comp);
    x_nonsig(x_sig_idx) = 0;
    
    % Find variables in Y that load on to the component.
    Y_sig = zeros(size(Y,2),1);
    Y_nonsig = zeros(size(Y,2),1);
    
    Y_sig_idx = abs(Y_bs_ratio) > bs_thresh;
    Y_nonsig_idx = abs(Y_bs_ratio) <= bs_thresh;
    
    Y_sig(Y_sig_idx) = Y_weights(Y_sig_idx,sig_comp);
    Y_nonsig(Y_nonsig_idx) = Y_weights(Y_nonsig_idx,sig_comp);
    Y_nonsig(Y_sig_idx) = 0;
    
    %% Plot.
    
    fig = figure('Position',[196 150 1499 817]);
    subplot(2,1,1)
    bar(x_sig,'k','FaceAlpha', .75);
    hold on;bar(x_nonsig,'k','FaceAlpha', .25);
    
    hold on;errorbar(x_weights(:,sig_comp),x_se,'color','k','LineStYle','none');
    set(gca,'XTick',1:n_comp, 'XTickLabel',[x_labels,{''}])
    title(['{\it X} latent variable ',num2str(sig_comp)])
    Ylabel('PLS loading')
    legend(['|BS-Ratio| > ',num2str(bs_thresh)])
    
    subplot(2,1,2)
    hold on;bar(Y_sig,'k','FaceAlpha', .75);
    hold on;bar(Y_nonsig,'k','FaceAlpha', .25);
    
    hold on;errorbar(Y_weights(:,sig_comp),Y_se,'color','k','LineStYle','none');
    set(gca,'XTick',1:n_comp, 'XTickLabel',[Y_labels,{''}])
    title(['{\it Y} latent variable ',num2str(sig_comp)])
    Ylabel('PLS loading')
    legend(['|BS-Ratio| > ',num2str(bs_thresh)])
    
    saveas(fig,[save_path,'latent_variable_',num2str(sig_comp),'.png'])

end