function comparison = comp_multcompare(reference, comparisons, alpha)
    
    comparison = zeros(length(comparisons), 7);
    parfor c=1:length(comparisons)
        current = comparisons{c};
        [AA, AD, PA, PD1, PD2, PAA, PPA] = comp(reference, current, alpha);
        comparison(c, :) = [AA, AD, PA, PD1, PD2, PAA, PPA] ;
    end
   
end

function [AA, AD, PA, PD1, PD2, PAA, PPA] = comp(ref, comparison, alpha)
    [AA, AD, PA, PD1, PD2] = deal(0);
    for l_ref_n=1:height(ref)
       l_ref = ref(l_ref_n, :);
       
       s11 = l_ref{1, 1};
       s12 = l_ref{1, 2};
       df1 = l_ref{1, 4};
       pv1 = l_ref{1, 6};
       
       
       %select only the corresponding row of the comparison
       l_comp = comparison(...
           (strcmp(comparison{:, 1},s11) & strcmp(comparison{:, 2}, s12))|...
           (strcmp(comparison{:, 1},s12) & strcmp(comparison{:, 2}, s11))...
       , :);
   
       [h, ~] = size(l_comp);
       assert(h==1);
       
       s21 = l_comp{1, 1};
       s22 = l_comp{1, 2};
       df2 = l_comp{1, 4};
       pv2 = l_comp{1, 6};
       
       
       % if the first test assesses A!=B
       if pv1<alpha
           % if the first second assesses A!=B
           if pv2<alpha
               %if the sign of the diffrence is equal
               if ((strcmp(s11,s21) && sign(df1) == sign(df2))|| ...
                   (~strcmp(s11,s21) && sign(df1) ~= sign(df2)))
                   AA = AA+1;
               %if the sign of the difference is different
               else
                   AD = AD+1;
               end
           % if only the first test assesses A!=B
           else
               PD1 = PD1 + 1;
           end
       %if only the second test assesses A!=B
       elseif pv2<alpha
           PD2 = PD2 + 1;
       %if no test finds any difference
       else
           PA = PA + 1;
       end    
    end
    
    PAA = 2*AA/(2*AA+PD1+PD2);
    PPA = 2*PA/(2*PA+PD1+PD2);

end