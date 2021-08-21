function [y, res, x1, x2, d1, d2, s1, s2,g, pe] = objective(x,p,a)
    n = 168;
    x1 = (x(1:n));                                                          % d�bit turbine 1
    x2 = (x(n+1:n*2));                                                      % d�bit turbine 2
    d1 = x1 * 1.07;                                                         % production turbine 1
    d2 = x2 * 1.10;                                                         % production turbine 2
    s1 = d1 * 3600;                                                         % rendement turbine 1
    s2 = d2 * 3600;                                                         % rendement turbine 2
    g = s1 + s2;                                                            % rendement global
    pe = [];
    % pour simulation : p = 324.94.*rand(n,1);
    % pour simulation : a = 609.0706.*rand(n,1) - 1.3806;
    V = 12500000;                                                           % volume initial � moiti� plein avant 1er apport
    res = [];
    s = 0;
    for i = 1:1:n
        k = n - i;
        if (k < 24)
            pf = (p(i:k));
        else
            pf = (p(i:i+24));                                               % observation des prix � 24 heures glissantes
        end
        if (V > 3600 * (x1(i)*1.07 + x2(i)*1.1))
            if (V >= 0.9360496 * 25000000 || p(i) > quantile(pf,0.75))      % contrainte volume max et fen�tre de prix
                x1(i) = 230;                                                % production max si contraintes valid�es
                x2(i) = 180;
            end
        else    
            x1(i) = 0;                                                      % production nulle si volume insuffisant
            x2(i) = 0;
        end
        V = V + 3600 * (a(i) - 2 - x1(i) - x2(i));                          % it�ration du volume
        res = [res ; V];                                                    % �volution du r�servoir
        R = (p(i) * (x1(i)*1.07 + x2(i)*1.1));                              % it�ration du revenu
        s = (s + R);                                                        % r�sultat de la somme
        pe = [pe ; s];                                                      % produit �conomique total
    end
    y = -s;                                                                 % maximisation
end