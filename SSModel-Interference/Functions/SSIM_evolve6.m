function [z, e, X] = SSIM_evolve6(k, input , x0)
%TIME DEPENDENT STUFF
% This is the FIRST version in the presentation
% Possible future edits:
%   1. Add the possibility of interference also in the fast state.
%       Hopefully the coefficients for the fast state will be very low
%   2. Fix the problems with the aftereffects. They are bigger for the
%   savings groups compared to the interference group
ntrials = length(input);

% Parameters extraction
kcell = num2cell(k);
[af,bf,bfet,as,bs,bset,bsint,aet,bet,NS1,NS2] = kcell{:};

%Initializations
z = zeros(1,ntrials);
xf = zeros(1,ntrials);
xs = zeros(1,ntrials);
xpe = zeros(1,ntrials); %
xne = zeros(1,ntrials); %
e = zeros(1,ntrials);

xf(1)  = x0(1);
xs(1)  = x0(2);
xpe(1) = x0(3);
xne(1) = x0(4);

%Evoulution
T = 0;
for n=1:ntrials-1
    % xf(n) = 0; %You just need to uncomment this in order t
    % xs(n) = 0
    z(n) = xf(n) + xs(n);
    e(n) = input(n) - z(n);        % Kinematic error previous step
    em   = abs(e(n));
    
    %% Reactive components update
    %     if n==2701
    %        disp('2701')
    %     end
    xf(n+1) = af*xf(n) + bf*e(n); % Error driven fast adaptation
    xs(n+1) = as*xs(n) + bs*e(n); % Error driven slow adaptation
    
    % Fast contextual tuning
    if e(n)>0
        xf(n+1) = xf(n+1) + bfet*xpe(n)*em;
    elseif e(n)<0
        xf(n+1) = xf(n+1) + bfet*xne(n)*em;
    else
    end
    
    % Timer update
    if n>1
        if e(n)*e(n-1) < 0 %Change in sign
            T = 0;
        else
            T = T + 1;
        end
    end
    % Time dependent weights computation
%     w = sqrt(T/NS); %For the very first trial, w=0
    w1 = T/(NS1+T);
    w2 = T/(NS2+T);

    % Slow contextual tuning
    if e(n)>0
        xs(n+1) = xs(n+1) + (1-w1)*bset*xpe(n)  + (w2)*bsint*xne(n);
    elseif e(n)<0
        xs(n+1) = xs(n+1) + (1-w1)*bset*xne(n)  + (w2)*bsint*xpe(n);
    else
    end
    
    %% Primitives update (effect of practice)
    % 1. Decay
    xpe(n+1) = aet*xpe(n);
    xne(n+1) = aet*xne(n);
    
    % 2. Increase
    if e(n)>0
        xpe(n+1) = xpe(n+1) + bet*e(n);
    elseif e(n)<0
        xne(n+1) = xne(n+1) + bet*e(n);
    else
    end

    
    
end
z(end) = xs(end)   +   xf(end);
e(end) = input(end) -   z(end);

X = [xf; xs; xpe; xne];
end