%run
clear, close all
kk=6; % 1
save('kk_temp','kk')
Maara=23
for pp=kk:Maara
    Dyn_NoCrop_MAIN
    close
end
%%
kk=15; % 1
save('kk_temp','kk')
Maara=15
for pp=kk
    Dyn_NoCrop_MAIN
    close
end