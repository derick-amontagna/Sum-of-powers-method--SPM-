function [vR,vX] = criandoVetorLinha(nBarra)
    vR = [];
    vX = [];
    disp("Entrada dos dados de linhas");
    for (i = 1:nBarra - 1)
        prox = i + 1;
        disp("O valor R da linha " + string(i)+"-"+string(prox) + " em Ohm");
        vR(i) = input("Digite:");
        disp("O valor X da linha " + string(i)+"-"+string(prox) + " em Ohm");
        vX(i) = input("Digite:");
    end
endfunction

function [vP,vQ] = criandoVetorCarga(nBarra)
    vP = [];
    vQ = [];
    disp("Entrada dos dados de Cargas");
    for (i = 1:nBarra)
        disp("O valor P do nó " + string(i)+ " em kW");
        vP(i) = input("Digite:");
        vP(i) = vP(i)*1000;
        disp("O valor Q do nó " + string(i)+ " em kVar");
        vQ(i) = input("Digite:");
        vQ(i) = vQ(i)*1000;
    end
endfunction

function [vT] = criandoVetorTensao(nBarra, tensaoBase)
    vT = [];
    for (i = 1:nBarra)
        vT(i) = tensaoBase;
    end
endfunction

function [Pnb, Qnb] = calcPotencia(nBarra, vP, vQ, vR, vX, vT, perdasP, perdasQ, interacao)
    Pnb = [];
    Qnb = [];
    for (i = nBarra:-1:1)
        if (i == nBarra) then
            Pnb(i) = vP(i);
            Qnb(i) = vQ(i);
        elseif (interacao == 1) then
            Pperdas = 0;
            Qperdas = 0;
            Pnb(i) = Pperdas + vP(i) + Pnb(i+1);
            Qnb(i) = Qperdas + vQ(i) + Qnb(i+1);
        else
            Pnb(i) = perdasP(i) + vP(i) + Pnb(i+1);
            Qnb(i) = perdasQ(i) + vQ(i) + Qnb(i+1);
        end
    end
    
endfunction

function [vTT] = calcTensao(nBarra, Pnb, Qnb, vR, vX, vT, tBase)
    vTT = [];
    vTT(1) = tBase;
    for (i = 2:nBarra)
        B = Pnb(i) * vR(i-1) + Qnb(i) * vX(i-1) - 0.5*(vT(i-1)^2);
        D = ((Pnb(i))^2+(Qnb(i))^2)*((vR(i-1))^2+(vX(i-1))^2);
        vTT(i) = sqrt(-B+sqrt((B)^2-D));
    end
endfunction

function [perdasP, perdasQ] = calcPerdas(nBarra, Pnb, Qnb, vR, vX, vTT)
    for (i = 1:nBarra-1)
            perdasP(i) = (vR(i)*((Pnb(i+1)^2)+(Qnb(i+1)^2)))/(vTT(i+1)^2);
            perdasQ(i) = (vX(i)*((Pnb(i+1)^2)+(Qnb(i+1)^2)))/(vTT(i+1)^2);
    end
endfunction

function [vErro] = calcErro(nBarra, vT, vTT, tol)
    vErroValor = [];
    vErroValor(1) = 0;
    vErro = [];
    vErro(1) = 1;
    for (i = 2:nBarra)
        vErroValor(i) = abs(vT(i)- vTT(i));
        if vErroValor(i) < tol then
            vErro(i) = 1;
        else
            vErro(i) = 0;
        end
    end
    
endfunction

function [vT] = trocaValores(nBarra,vT, vTT)
    for (i = 1:nBarra)
        vT(i) = vTT(i)
    end
endfunction

function [pP, pQ] = calcPerdasTotais(nBarra, perdasP, perdasQ)
    pP = 0;
    pQ = 0;
    for (i = 1:nBarra-1)
            pP = pP + perdasP(i);
            pQ = pQ + perdasQ(i);
    end
endfunction

function [vBase]= calcTensaoBase(nBarra, vT, tBase)
    vBase = [];
    for (i = 1:nBarra)
        vBase(i) = vT(i) / tBase;
    end
endfunction

function [erro] = somaErro(nBarra, vErro)
    erro = 0;
    for (i = 1:nBarra)
        erro = erro + vErro(i);
    end
endfunction

function mostravalores(nBarra, tBase, tol, vR, vX, vP, vQ)
    disp("+++++++++++++++++++++++++++++++++++++++++++++++++++");
    disp("A tensão base é "+string(tBase)+ " V" + " e a tolerância é " +string(tol));
    disp("Nó---Linhas---Pl(W)-------Ql(W)-------R(Ohm)-------X(Ohm)-------");
    for (i = 1:nBarra)
        if (i ~= nBarra) then
            tensao = vP(i);
            q = vQ(i);
            p = vP(i);
            resis = vR(i);
            xx = vX(i);
            prox = i + 1;
          else
            tensao = vP(i);
            q = vQ(i);
            p = vP(i);
            resis = 0;
            xx = 0;
            prox = i;
          end
              
        disp(" "+string(i)+"    "+string(i)+"-"+string(prox)+"       "+string(p)+"     "+string(q)+"     "+string(resis)+"     "+string(xx));
    end
    disp('');
    ok = input('Pressione qualquer botão para continuar');
endfunction


disp("Fluxo de Potência MSP");
nBarras = input("Digite o numero de barras: ");
tBase = input("Digite a tensão base em V: ");
tol = input("Digite a tolerancia: ");
disp("Digite 0 para o modo novo / digite 1 para o modo do trabalho");
modo = input('Digite: ')
if modo == 1 then
    vR = [1.090, 1.104, 2.005, 3.088, 1.003, 1.002, 4.003, 5.042, 2.090, 1.504, 1.230, 2.100, 3.309];
    vX = [0.405, 0.404, 0.803, 1.029, 0.405, 0.407, 1.315, 1.697, 0.718, 0.408, 0.350, 0.708, 1.103];
    vP = [0, 60, 58, 54, 50, 50, 56, 50, 50, 48, 44, 40, 36, 32] * 1000;
    vQ = [0, 30, 29, 27, 25, 25, 28, 25, 25, 24, 22, 20, 18, 16] * 1000;
else
    [vR,vX] = criandoVetorLinha(nBarras);
    [vP,vQ] = criandoVetorCarga(nBarras);
end

[vT] = criandoVetorTensao(nBarras, tBase);

mostravalores(nBarras, tBase, tol, vR, vX, vP, vQ);

interacao = 0;
erro = 0;
perdasP = zeros(nBarras-1, 1);
perdasQ = zeros(nBarras-1, 1);

while (erro ~= nBarras)
    interacao = interacao + 1;
    [Pnb, Qnb] = calcPotencia(nBarras, vP, vQ, vR, vX, vT, perdasP, perdasQ, interacao);
    [vTT] = calcTensao(nBarras, Pnb, Qnb, vR, vX, vT,tBase);
    [perdasP, perdasQ] = calcPerdas(nBarras, Pnb, Qnb, vR, vX, vTT);
    [vErro] = calcErro(nBarras, vT, vTT, tol);
    [vT] = trocaValores(nBarras,vT, vTT);
    [erro] = somaErro(nBarras, vErro);
end

[Pp, Qp] = calcPerdasTotais(nBarras, perdasP, perdasQ);
[vBase]= calcTensaoBase(nBarras, vT, tBase);
disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp('Levou ' + string(interacao) + ' interação para terminar');
disp('---------------------');
disp('As suas perdas foram:');
disp("P: " + string(Pp/1000) + " kW");
disp("Q: " + string(Qp/1000) + " kVar");
disp('---------------------');
disp("Suas tensões foram: "); 
for (i = 1:nBarras)
    tensao = vBase(i);
    disp("V" + string(i) + ": " + string(tensao)+ " pu"); 
end
disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp('+++++++++++++++++++++++++++++++++++++++++FIM++++++++++++++++++++++++++++++++++++++++++');
