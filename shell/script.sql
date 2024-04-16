CREATE SCHEMA IF NOT EXISTS `codeup`;
USE `codeup` ;

-- -----------------------------------------------------
-- Table `codeup`.`materia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeup`.`materia` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `titulo` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`)
  );

-- -----------------------------------------------------
-- Table `codeup`.`fase`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeup`.`fase` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `titulo` VARCHAR(100) NOT NULL,
  `num_fase` INT NOT NULL,
  `materia_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_materia1`
    FOREIGN KEY (`materia_id`)
    REFERENCES `codeup`.`materia` (`id`)
    ON DELETE CASCADE
    );


-- -----------------------------------------------------
-- Table `codeup`.`exercicio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeup`.`exercicio` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `num_exercicio` INT NOT NULL,
  `conteudo_teorico` TEXT NOT NULL,
  `desafio` TEXT NULL,
  `instrucao` TEXT NULL,
  `layout_funcao` TEXT NOT NULL,
  `fase_id` INT NOT NULL,
  `titulo` VARCHAR(100) NOT NULL ,
  `moeda` INT NOT NULL DEFAULT 0,
  `xp` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE `num_exercicio_unico_por_fase` (`num_exercicio`, `fase_id`),
  CONSTRAINT `fk_fase1`
    FOREIGN KEY (`fase_id`)
    REFERENCES `codeup`.`fase` (`id`)
    ON DELETE CASCADE
    );

-- -----------------------------------------------------
-- Table `codeup`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeup`.`usuario` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `foto_perfil` varchar(255),
  `nome` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `senha` VARCHAR(255) NULL ,
  `dt_nascimento` DATE NOT NULL,
  `xp` INT DEFAULT 0,
  `nivel` INT DEFAULT 0,
  `moedas` INT DEFAULT 0,
  PRIMARY KEY (`id`)
  );

-- -----------------------------------------------------
-- Table `codeup`.`exercicio_usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeup`.`exercicio_usuario` (
  `concluido` TINYINT NOT NULL DEFAULT 0,
  `usuario_id` INT NOT NULL,
  `exercicio_id` INT NOT NULL,
  `id` INT NOT NULL AUTO_INCREMENT,
  `resposta_usuario` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_usuario1`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `codeup`.`usuario` (`id`)
     ON DELETE CASCADE,
  CONSTRAINT `fk_exercicio1`
    FOREIGN KEY (`exercicio_id`)
    REFERENCES `codeup`.`exercicio` (`id`)
    ON DELETE CASCADE
    );

-- -----------------------------------------------------
-- Table `codeup`.`item_loja`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeup`.`item_loja` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(255) NOT NULL ,
  `nome` VARCHAR(255) NOT NULL ,
  `preco` INT NOT NULL ,
  `tipo` VARCHAR(255)NOT NULL,
  `imagem` varchar(255) NULL ,
  PRIMARY KEY (`id`)
);

-- -----------------------------------------------------
-- Table `codeup`.`item_adquirido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `codeup`.`item_adquirido` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `equipado` TINYINT NOT NULL DEFAULT FALSE,
  `item_loja_id` INT NOT NULL,
  `usuario_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_usuario2`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `codeup`.`usuario` (`id`)
	ON DELETE CASCADE,
  CONSTRAINT `fk_item_loja1`
    FOREIGN KEY (`item_loja_id`)
    REFERENCES `codeup`.`item_loja` (`id`)
	ON DELETE CASCADE
    );
    
CREATE TABLE IF NOT EXISTS `codeup`.`fase_usuario` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `desbloqueada` TINYINT NOT NULL DEFAULT FALSE,
  `usuario_id` INT NOT NULL,
  `fase_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_usuario3`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `codeup`.`usuario` (`id`)
	ON DELETE CASCADE,
  CONSTRAINT `fk_fase2`
    FOREIGN KEY (`fase_id`)
    REFERENCES `codeup`.`fase` (`id`)
	ON DELETE CASCADE
    );  
-- PROCEDURE DESBLOQUAR FASE -- 
DELIMITER //
CREATE PROCEDURE atualizarFaseDesbloqueadaParaUsuario(IN usuario_id INT, IN fase_atual INT)
BEGIN
    DECLARE total_exercicios INT;
    DECLARE exercicios_concluidos INT;
    DECLARE total_fases INT;

    -- Conta o total de exercícios da fase atual para o usuário específico
    SELECT COUNT(*) INTO total_exercicios
    FROM exercicio_usuario eu
    INNER JOIN exercicio e ON eu.exercicio_id = e.id
    WHERE e.fase_id = fase_atual AND eu.usuario_id = usuario_id;

    -- Conta o total de exercícios da fase atual concluídos pelo usuário específico
    SELECT COUNT(*) INTO exercicios_concluidos
    FROM exercicio_usuario eu
    INNER JOIN exercicio e ON eu.exercicio_id = e.id
    WHERE e.fase_id = fase_atual AND eu.usuario_id = usuario_id AND eu.concluido = 1;

    -- Verifica o total de fases existentes no sistema
    SELECT COUNT(*) INTO total_fases
    FROM fase;

    -- Se todos os exercícios da fase atual para o usuário estão concluídos
    IF total_exercicios = exercicios_concluidos THEN
        -- Verifica se existe uma próxima fase para desbloquear
        IF fase_atual + 1 <= total_fases THEN
            -- Atualiza a próxima fase (fase_atual + 1) para desbloqueada = true para o usuário específico
            UPDATE fase_usuario fu
            SET fu.desbloqueada = TRUE
            WHERE fu.fase_id = fase_atual + 1 AND fu.usuario_id = usuario_id;
        END IF;
    END IF;
END; //
DELIMITER ;
-- TRIGGER ADICIONA EXERCICIO_USUARIO QUANDO UM USUARIO É ADICIONADO --
DELIMITER //
CREATE TRIGGER adicionar_usuario_trigger
AFTER INSERT ON usuario
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE exercicio_id INT;
    DECLARE cur_exercicios CURSOR FOR SELECT id FROM exercicio;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_exercicios;

    read_loop: LOOP
        FETCH cur_exercicios INTO exercicio_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO exercicio_usuario (concluido, usuario_id, exercicio_id, resposta_usuario)
        VALUES (FALSE, NEW.id, exercicio_id, NULL);
    END LOOP;

    CLOSE cur_exercicios;
END; //
DELIMITER ;
-- TRIGGER ADICIONA EXERCICIO_USUARIO QUANDO UM EXERCICIO É ADICIONADO -- 	
DELIMITER //
CREATE TRIGGER adicionar_exercicio_usuario_trigger
AFTER INSERT ON exercicio
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE usuario_id INT;
    DECLARE cur_usuarios CURSOR FOR SELECT id FROM usuario;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_usuarios;
    read_loop: LOOP
        FETCH cur_usuarios INTO usuario_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO exercicio_usuario (concluido, usuario_id, exercicio_id, resposta_usuario)
        VALUES (FALSE, usuario_id, NEW.id, NULL);
    END LOOP;

    CLOSE cur_usuarios;
END; //
DELIMITER ;
-- TRIGGER ADICIONA  FASE_USUARIO QUANDO UM USUARIO É ADICIONADO -- 	
DELIMITER //
CREATE TRIGGER adicionar_usuario_fase_trigger
AFTER INSERT ON usuario
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE fase_id INT;
    DECLARE cur_fases CURSOR FOR SELECT id FROM fase;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_fases;

    read_loop: LOOP
        FETCH cur_fases INTO fase_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO fase_usuario (usuario_id, fase_id)
        VALUES (NEW.id, fase_id);
    END LOOP;

    CLOSE cur_fases;
END; //
DELIMITER ;
-- TRIGGER ADICIONA  FASE_USUARIO QUANDO UMA FASE É ADICIONADA -- 
DELIMITER //
CREATE TRIGGER adicionar_fase_usuario_trigger
AFTER INSERT ON fase
FOR EACH ROW
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE usuario_id INT;
    DECLARE cur_usuarios CURSOR FOR SELECT id FROM usuario;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_usuarios;

    read_loop: LOOP
        FETCH cur_usuarios INTO usuario_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO fase_usuario (usuario_id, fase_id)
        VALUES (usuario_id, NEW.id);
    END LOOP;

    CLOSE cur_usuarios;
END; //
DELIMITER ;
-- TRIGGER DESBLOQUEIA FASE COM NUM_FASE = 1 --
DELIMITER //
CREATE TRIGGER definir_desbloqueio_fase_usuario
BEFORE INSERT ON fase_usuario
FOR EACH ROW
BEGIN
    DECLARE fase_num_fase INT;

    -- Obter o num_fase da fase inserida na fase_usuario
    SELECT num_fase INTO fase_num_fase
    FROM fase
    WHERE id = NEW.fase_id;

    -- Verificar se num_fase é igual a 1 e definir desbloqueada
    IF fase_num_fase = 1 THEN
        SET NEW.desbloqueada = TRUE;
    ELSE
        SET NEW.desbloqueada = FALSE;
    END IF;
END; //
DELIMITER ;
-- TRIGGER PARA DEFINIR FOTO DE PERFIL
DELIMITER //
CREATE TRIGGER definir_foto
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
    -- Atualiza a foto de perfil para o novo usuário
    SET NEW.moedas = 0;
	SET NEW.xp = 0;
    SET NEW.nivel = 0;
    SET NEW.foto_perfil = "https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn";
    END;


-- TRIGGER PARA ADICIONAR ITEM ADQUIRIDO AO INSERIR UM NOVO USUÁRIO --
CREATE TRIGGER adicionar_item_ao_inserir_usuario
AFTER INSERT ON usuario
FOR EACH ROW
BEGIN
    -- Substitua os valores pelos adequados para o item desejado
    INSERT INTO item_adquirido (equipado, item_loja_id, usuario_id)
    VALUES (true, 15, NEW.id);
END; //
DELIMITER ;

select * from item_loja;
SELECT * FROM codeup.materia;
SELECT * FROM codeup.fase;
SELECT * FROM codeup.exercicio;
SELECT * FROM codeup.usuario;
SELECT * FROM codeup.exercicio_usuario;
SELECT * FROM codeup.item_loja;
SELECT * FROM codeup.item_adquirido;
SELECT * FROM codeup.fase_usuario;

use codeup;
INSERT INTO item_loja
    (descricao, nome, preco, tipo, imagem)
VALUES
    ("Astronauta", "Astronauta", 20, "Imagem", "https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Candy", "Candy", 20, "Imagem", "https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Castelo", "Castelo", 20, "Imagem", "https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Castelo Antigo", "Castelo Antigo", 20, "Imagem", "https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Raposa", "Raposa", 20, "Imagem", "https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Fantasminha", "Fantasminha", 20, "Imagem", "https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn");
    
use codeup;
    INSERT INTO item_loja
    (descricao, nome, preco, tipo, imagem)
	VALUES
    ("Garota", "Garota", 20, "Imagem", "https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Halloween", "Halloween", 20, "Imagem","https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Gato preto", "Gato preto", 20, "Imagem","https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Casa", "Casa", 20, "Imagem","https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Penguim", "Penguim", 20, "Imagem","https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Reuniao", "Reuniao", 20, "Imagem","https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn");
    
use codeup;
    INSERT INTO item_loja
    (descricao, nome, preco, tipo, imagem)
	VALUES
    ("Rio", "Rio", 20, "Imagem","https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Robô", "Robô", 20, "Imagem","https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn"),
    ("Padrão", "Padrão", 0, "Imagem","https://th.bing.com/th/id/OIG1.oY3TKqD93NExwROX0cEx?pid=ImgGn");
    
    use codeup;

show tables;   
 --  desc materia;
 --   select * from materia limit 10;
insert into materia (titulo) values ('Algoritmos');

insert into usuario
    (nome, dt_nascimento, email, senha, xp, nivel, moedas)
values
    ('Desenvolvedor', '2002-02-13','dev@sptech.school', '$2a$10$jRIZerJIQ8tnf9mT5fgI2ODD.X7KHnApVHS/kaDRiG1HtuZ7nipH2',100000,100,2000),
    ('Thiago Serafim', '1992-03-10', 'antonio.pereira@outlook.com', '$2a$10$jRIZerJIQ8tnf9mT5fgI2ODD.X7KHnApVHS/kaDRiG1HtuZ7nipH2', 52000, 52,2999);

insert into fase
    (num_fase, titulo, materia_id)
values
    (1,'Introdução', 1),
    (2,'Operadores Lógicos', 1),
    (3,'Parametros', 1),
    (4,'Em breve', 1),
    (5,'Em breve', 1),
    (6,'Em breve', 1),
    (7,'Em breve', 1),
    (8,'Em breve', 1);
    
INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
values
    (1, 'Variáveis "var" e "const":',
    'Imagine que você tem duas caixas: uma chamada var e outra chamada const . Essas caixas são especiais porque você pode guardar coisas dentro delas, como brinquedos, doces ou qualquer outra coisa que você queira guardar.^A caixa chamada var é como uma caixa mágica que você pode abrir a qualquer momento e trocar o que está dentro. Por exemplo, se você colocar um brinquedo e depois decidir que prefere guardar um doce, pode abrir a caixa var e fazer essa troca.^Já a caixa chamada const é um pouco diferente. É como uma caixa que, uma vez que você coloca alguma coisa dentro, não pode mais mudar. Se você decide colocar um brinquedo na caixa const, ela fica lá para sempre, e você não pode tirar o brinquedo de lá ou trocar por outra coisa.^Resumindo, var é uma caixa que você pode abrir e trocar as coisas quantas vezes quiser, enquanto const é uma caixa onde você coloca algo uma vez e não pode mais mexer nisso. É como decidir se você quer uma caixa mágica que pode ser mudada a qualquer momento ou uma caixa onde o que você coloca fica lá para sempre.',
    'Desafio do Exercício 1',
    '1. Passo: Escreva var texto =^2. Passo: Após isso, coloque uma palavra entre " " (exemplo "batata")^3. Passo: Coloque ; no final (exemplo: var texto = "Olá Mundo";)^4. Passo: Clique em Verificar^', 
    'function primeiraVariavel() {{resposta} return verificarTexto(texto);}function verificarTexto(texto) {if (texto.length > 0) {return texto;} else {return false;}} primeiraVariavel()',200,100,1);

-- INSERT INTO exercicio
  --   (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
-- VALUES
  --  (2, 'Escrever no console',
   -- 'Introdução ao Console e Mensagens^Imagine que você está prestes a enviar uma mensagem importante para todas as pessoas em volta usando um megafone. No mundo da programação, o console.log funciona de maneira semelhante. É como se você estivesse gritando uma mensagem no computador, e a mensagem aparecerá na tela.^Passo 2: Escrevendo a Mensagem^Agora, imagine que você está digitando a mensagem que deseja que todos ouçam. No mundo da programação, você escreverá o seguinte comando:^```javascript^console.log("Hello, World!");^```^Aqui, console.log é como o megafone, e "Hello, World!" é a mensagem que você deseja mostrar.^Passo 3: Salvando e Executando^Depois de escrever sua mensagem, salve o arquivo. Agora, assim como você precisaria apertar um botão para fazer o megafone soar, no mundo da programação, você executa o programa. Isso pode envolver pressionar um botão chamado "Run" no seu editor de código ou executar um comando específico, dependendo do ambiente que você está usando. No nosso caso, basta clicar em Verificar!^Passo 4: Observando a Mensagem^Assim como as pessoas ouviriam sua mensagem quando você gritasse no megafone, agora você verá sua mensagem no console do seu computador. O "Hello, World!" será exibido na tela.^Parabéns, você acaba de criar e validar seu primeiro programa em JavaScript! Este é um passo importante na jornada da programação, e há muitos mais conceitos interessantes que você pode explorar a partir daqui. Divirta-se explorando e aprendendo mais!',
    -- 'Desafio do Exercício 2',
 --   '1. Passo: Escreva console.log( )^2. Passo: Escreva dentro do console a mensagem "Hello, World!" entre aspas duplas^3. Passo: Clique em Verificar',
 --   'function escreverNoConsole() {{resposta};}', 200, 10, 2);


INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (2, 'Soma',
    'Os operadores numéricos são como sinais de matemática que o computador entende. Vamos pensar neles como ferramentas matemáticas que ajudam o computador a fazer cálculos, assim como você usaria uma calculadora para resolver problemas de matemática.^Vamos começar com adição:^^Adição (+): Este operador é como o sinal de mais em matemática. Ele adiciona dois números.',
    'Desafio do Exercício 3',
    '1. Passo: Crie duas var, e coloque que elas são iguais a algum número maior que 0 de sua escolha^2. Passo: Crie uma var chamada soma.^3. Passo: Coloque que a var soma recebe o primeiro número + o segundo número (dica: var soma = n1+n2).^4. Passo: Clique em Verificar.',
    'function operadoresNumericos() {{resposta} if(soma > 1){return soma}else{return false}}; operadoresNumericos()', 200, 100, 2);

INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (3, 'Subtração: O Encanto da Diferença',
    'A subtração é uma operação matemática que nos permite descobrir quanto um número é menor que outro. No mundo da programação, usamos a subtração para encontrar a diferença entre dois números.^^Subtração (-): Este operador é como o sinal de menos em matemática. Ele subtrai um número do outro.',
    'Desafio do Exercício 4',
    '1. Passo: Crie duas var, e coloque que elas são iguais a algum número maior que 0 de sua escolha. Obs: Um número deve ser maior que o outro de forma que a subtração fique menor que 1^2. Passo: Crie uma var chamada subtracao.^3. Passo: Coloque que a var subtracao recebe o primeiro número - o segundo número (dica: var subtracao = n1-n2).^4. Passo: Clique em Verificar.',
    'function operadoresNumericos() {{resposta} if( subtracao < 1){return subtracao}else{return false}}; operadoresNumericos()', 200, 10, 2);

-- Exercício 5
INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (4, 'Multiplicação: O Reino dos Números em Crescimento',
    'A multiplicação é como um truque mágico que nos permite encontrar o resultado de repetir algo várias vezes. Em programação, usamos a multiplicação para calcular o resultado de repetir uma quantidade específica de vezes.^Multiplicação (*): Este operador é como o sinal de multiplicação em matemática. Ele multiplica dois números.',
    'Desafio do Exercício 5',
    '1. Passo: Crie duas var, e coloque que elas são iguais a algum número maior que 0 de sua escolha. Passo: Crie uma var chamada multiplicacao.^3. Passo: Coloque que a var multiplicacao recebe o primeiro número * o segundo número (dica: var multiplicacao = n1*n2).^4. Passo: Clique em Verificar.',
    'function operadoresNumericos() {{resposta} if( multiplicacao > 1){return multiplicacao}else{return multiplicacao}}; operadoresNumericos()', 200, 10, 2);

-- Exercício 6
INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (5, 'Divisão: A Arte do Compartilhamento',
    'A divisão é como dividir uma quantidade em partes iguais. Na programação, usamos a divisão para distribuir uma quantidade em partes específicas.^Divisão (/): Este operador é como o sinal de divisão em matemática. Ele divide um número pelo outro.',
    'Desafio do Exercício 6',
    '1. Passo: Crie duas var, e coloque que elas são iguais a algum número maior que 0 de sua escolha. Obs: De forma que o resto da divisão seja zero (exemplo: 2 divido por 2 é igual a 0)^2. Passo: Crie uma var chamada divisao.^3. Passo: Coloque que a var divisao recebe o primeiro número / o segundo número (dica: var divisao = n1/n2).^4. Passo: Clique em Verificar.',
    'function operadoresNumericos() {{resposta} if(divisao == 0){return divisao}else{return divisao}}; operadoresNumericos()', 200, 10, 2);


-- Exercicio 7
INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (6, 'Calculadora Simples - A Mágica dos Números',
    'Uma calculadora é como uma assistente mágica que nos ajuda a realizar cálculos matemáticos de maneira fácil. Em programação, podemos criar uma calculadora simples que aceita dois números do usuário e realiza operações de soma, subtração, multiplicação e divisão.^Passo a Passo:^Boas-vindas Mágicas: Cumprimentamos o usuário, criando uma atmosfera acolhedora.^Pergunta Encantadora: Pedimos ao usuário para nos fornecer dois números mágicos.^Recebendo Respostas: Guardamos esses números mágicos em nossas caixas especiais (variáveis).^Escolha da Operação: Perguntamos qual operação mágica o usuário deseja realizar (soma, subtração, multiplicação ou divisão).^Execução da Mágica: Usamos as operações matemáticas para realizar a mágica escolhida com os números mágicos.^Revelação do Resultado: Mostramos o resultado mágico para o usuário, para que todos possam testemunhar a magia acontecendo.^Agradecimento Especial: Agradecemos ao usuário por participar da mágica matemática.^Bem-vindo à Calculadora Mágica!^Por favor, forneça o primeiro número mágico: [Digite o número aqui]^Agora, o segundo número mágico: [Digite o número aqui]^Escolha a operação mágica:^1. Soma^2. Subtração^3. Multiplicação^4. Divisão^Digite o número correspondente à sua escolha: [Digite o número aqui]^Resultado Mágico: [Mostramos o resultado aqui]^Obrigado por participar da Mágica dos Números!^Em JavaScript como tudo isso ficaria, Vamos dar uma olhada:^// Boas-vindas Mágicas^alert("Bem-vindo à Calculadora Mágica!");^// Pergunta Encantadora^let primeiroNumero = parseFloat(prompt("Por favor, forneça o primeiro número mágico:"));^let segundoNumero = parseFloat(prompt("Agora, o segundo número mágico:"));^// Escolha da Operação^let escolhaOperacao = prompt("Escolha a operação mágica:\^1. Soma\^2. Subtração\^3. Multiplicação\^4. Divisão");^escolhaOperacao = parseInt(escolhaOperacao);^// Execução da Mágica^let resultado;^OBS: Utilizar Switch para dar as opção^Em programação, switch é uma estrutura de controle de fluxo utilizada para tomar decisões com base no valor de uma expressão. A ideia é comparar o valor dessa expressão com diversos casos possíveis e executar o bloco de código correspondente ao caso que corresponde ao valor da expressão.^A estrutura básica de um switch em várias linguagens de programação, incluindo JavaScript, é semelhante à seguinte:^Exemplo:^switch (expressao) {^  case valor1:^    // código a ser executado se expressao for igual a valor1^    break;^  case valor2:^    // código a ser executado se expressao for igual a valor2^    break;^  // mais casos podem ser adicionados conforme necessário^  default:^    // código a ser executado se nenhum caso corresponder^}^Aqui estão alguns pontos-chave sobre o switch:^Expressão: É a expressão cujo valor será comparado com os diferentes casos.^Caso (case): Cada case representa um valor possível que a expressão pode ter. Se o valor da expressão coincidir com o valor do case, o bloco de código associado a esse case será executado.^break: Após a execução de um bloco de código associado a um case, o break é usado para sair do switch e continuar a execução após o switch. Se o break não for utilizado, a execução continuará nos casos subsequentes, mesmo que seus valores não coincidam.^default: O bloco de código associado ao default será executado se nenhum dos casos corresponder ao valor da expressão. O default é opcional.^// Revelação do Resultado^alert("Resultado Mágico: " + resultado);^// Agradecimento Especial^alert("Obrigado por participar da Mágica dos Números!");',
    'Desafio do Exercício 7',
    '1. Passo: Crie uma função chamada `calculadoraMagica` que implementa o processo descrito.^2. Passo: Utilize um switch para lidar com diferentes operações (soma, subtração, multiplicação, divisão).^3. Passo: A função deve retornar o resultado da operação escolhida.^4. Passo: Execute a função para diferentes conjuntos de números e operações.^5. Passo: Clique em Verificar.',
    'function calculadoraMagica(primeiroNumero, segundoNumero, operacao) {^    // Seu código aqui^}', 300, 20, 3);

-- Exercicio 8
INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (7, 'if',
    'A estrutura de controle if é um elemento fundamental em programação e é usado para tomar decisões com base em condições. Ela permite que o programa execute diferentes blocos de código dependendo se uma condição é avaliada como verdadeira ou falsa.^A estrutura básica do if é a seguinte:^javascript^if (condicao) {^  // código a ser executado se a condição for verdadeira^}^Aqui estão os principais componentes:^Condição: É uma expressão que é avaliada como verdadeira (true) ou falsa (false). Se a condição é verdadeira, o bloco de código dentro do if é executado.^Bloco de código: É o conjunto de instruções que será executado se a condição for verdadeira. O bloco é delimitado por chaves {}.^Vamos fazer um exemplo simples:^let idade = 18;^if (idade >= 18) {^  console.log("Você é maior de idade.");^}^Neste exemplo, se a variável idade for maior ou igual a 18, a mensagem "Você é maior de idade." será exibida.^Objetivo: Escreva um programa simples que verifica se uma pessoa é MENOR de idade.^Instruções:^Pergunte à pessoa sua idade.^Use um if para verificar se a idade é igual ou INFERIOR a 18.^Se a idade for 18 ou superior, exiba uma mensagem indicando que a pessoa é maior de idade. Caso contrário, exiba uma mensagem indicando que a pessoa é menor de idade.',
    'Desafio do Exercício 8',
    '1. Passo: Crie um programa que solicita a idade da pessoa.^2. Passo: Use um if para verificar se a idade é inferior a 18.^3. Passo: Se a idade for inferior a 18, exiba uma mensagem indicando que a pessoa é menor de idade.^4. Passo: Se a idade for 18 ou superior, exiba uma mensagem indicando que a pessoa é maior de idade.^5. Passo: Clique em Verificar.',
    'function verificarIdade(idade) {^    // Seu código aqui^}', 150, 10, 3);

INSERT INTO exercicio
    (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (8, 'Contagem de Números Pares e Ímpares: Passo a Passo',
    'Vamos criar um programa simples em JavaScript para contar e exibir quantos números pares e ímpares existem em uma lista. Aqui está um passo a passo em conceito:^1. Definir a Lista de Números:^Primeiro, precisamos de uma lista de números. Podemos representar isso como uma array em JavaScript.^2. Inicializar Contadores:^Vamos criar duas variáveis, uma para contar números pares e outra para contar números ímpares. Inicializaremos ambas com zero.^3. Percorrer a Lista de Números:^Vamos usar um loop (uma estrutura de repetição) para percorrer cada número na lista.^4. Verificar se o Número é Par ou Ímpar:^Para cada número, usaremos uma estrutura condicional if para verificar se é par ou ímpar. Isso é feito usando o operador de módulo (%), que retorna o resto da divisão.^5. Atualizar Contadores:^Conforme verificamos cada número, aumentaremos o contador correspondente (pares ou ímpares).^6. Exibir Resultados:^No final, exibiremos os resultados, ou seja, o número total de pares e ímpares.',
    'Desafio do Exercício 9',
    '// Passo 1: Definir a Lista de Números^const listaNumeros = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];^// Passo 2: Inicializar Contadores^let contadorPares = 0;^let contadorImpares = 0;^// Passo 3: Percorrer a Lista de Números^for (let numero of listaNumeros) {^  // Passo 4: Verificar se o Número é Par ou Ímpar^  if (numero % 2 === 0) {^    // Passo 5: Atualizar Contador de Números Pares^    contadorPares++;^  } else {^    // Passo 5: Atualizar Contador de Números Ímpares^    contadorImpares++;^  }^}^// Passo 6: Exibir Resultados^console.log(`Total de Números Pares: ${contadorPares}`);^console.log(`Total de Números Ímpares: ${contadorImpares}`);',
    'function contarParesImpares() { /* Implemente a resposta aqui */ }', 200, 20, 3);


INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (9, 'Contagem de Números Pares e Ímpares: Passo a Passo',
    'Vamos criar um programa simples em JavaScript para contar e exibir quantos números pares e ímpares existem em uma lista. Aqui está um passo a passo em conceito:^1. Definir a Lista de Números:^Primeiro, precisamos de uma lista de números. Podemos representar isso como uma array em JavaScript.^2. Inicializar Contadores:^Vamos criar duas variáveis, uma para contar números pares e outra para contar números ímpares. Inicializaremos ambas com zero.^3. Percorrer a Lista de Números:^Vamos usar um loop (uma estrutura de repetição) para percorrer cada número na lista.^4. Verificar se o Número é Par ou Ímpar:^Para cada número, usaremos uma estrutura condicional if para verificar se é par ou ímpar. Isso é feito usando o operador de módulo (%), que retorna o resto da divisão.^5. Atualizar Contadores:^Conforme verificamos cada número, aumentaremos o contador correspondente (pares ou ímpares).^6. Exibir Resultados:^No final, exibiremos os resultados, ou seja, o número total de pares e ímpares.^// Passo 1: Definir a Lista de Números^const listaNumeros = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];^// Passo 2: Inicializar Contadores^let contadorPares = 0;^let contadorImpares = 0;^// Passo 3: Percorrer a Lista de Números^for (let numero of listaNumeros) {^  // Passo 4: Verificar se o Número é Par ou Ímpar^  if (numero % 2 === 0) {^    // Passo 5: Atualizar Contador de Números Pares^    contadorPares++;^  } else {^    // Passo 5: Atualizar Contador de Números Ímpares^    contadorImpares++;^  }^}^// Passo 6: Exibir Resultados^console.log(`Total de Números Pares: ${contadorPares}`);^console.log(`Total de Números Ímpares: ${contadorImpares}`);',
    'Desafio do Exercício 10',
    '1. Crie uma array chamada `outraListaNumeros` com mais números para testar o programa.^2. Modifique o código para contar os números pares e ímpares em `outraListaNumeros`.^3. Execute o código e veja os resultados para a nova lista.',
    'function contarParesEImpares(lista) {^    // Seu código aqui^}', 120, 8, 3);


INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (10, 'Calculadora de Média',
    'Média de um Conjunto de Números^A média é uma medida estatística que representa o valor central de um conjunto de números. Para calcular a média, você soma todos os números e divide pelo total de elementos no conjunto. A fórmula da média (μ) é:^μ= Soma dos Números / Total de Números',
    'Desafio do Exercício 11',
    '1. Defina uma função chamada `calcularMedia` que recebe um array de números como parâmetro.^2. Dentro da função, crie variáveis para armazenar a soma dos números, o total de números e a média.^3. Use uma estrutura de repetição para percorrer o array e calcular a soma dos números.^4. Calcule a média usando a fórmula apresentada no conteúdo teórico.^5. Exiba a média no console.^6. Execute a função com diferentes conjuntos de números.',
    'function calcularMedia(numeros) {^    // Seu código aqui^}', 130, 10, 3);


INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (11, 'Calculadora de IMC',
    'Índice de Massa Corporal (IMC)^O Índice de Massa Corporal (IMC) é uma medida que utiliza a altura e o peso de uma pessoa para avaliar se ela está abaixo do peso, com peso normal, com sobrepeso ou obesa. A fórmula do IMC é dada por:^IMC= Peso em Quilogramas / Altura em Metros^²^Os intervalos de classificação geralmente são:^- Abaixo do peso: IMC < 18.5^- Peso normal: 18.5 <= IMC < 24.9^- Sobrepeso: 25 <= IMC < 29.9^- Obeso: IMC >= 30',
    'Desafio do Exercício 12',
    '1. Defina uma função chamada `classificarIMC` que recebe o peso e a altura como parâmetros.^2. Dentro da função, use a fórmula do IMC para calcular o índice.^3. Com base no valor do IMC, determine em qual categoria o usuário se encaixa (abaixo do peso, peso normal, sobrepeso ou obeso).^4. Exiba a classificação no console.^5. Execute a função com diferentes valores de peso e altura.',
    'function classificarIMC(peso, altura) {^    // Seu código aqui^}', 140, 12, 3);


INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (12, 'Simulador de Banco',
    'Simulador de Banco^Um simulador de banco é um programa que simula operações bancárias básicas, como depósitos, saques e a verificação do saldo em uma conta fictícia. Essa aplicação visa oferecer ao usuário uma experiência simulada de gerenciamento financeiro, permitindo interações como em um banco real.',
    'Desafio do Exercício 13',
    '1. Defina variáveis para representar o saldo da conta e armazenar as transações.^2. Implemente funções para depósito, saque e verificação de saldo.^3. Utilize um loop para permitir ao usuário realizar várias operações consecutivas.^4. Apresente um menu de opções, como depósito, saque, verificar saldo e sair.^5. Ao encerrar as operações, exiba um agradecimento e liste todas as transações realizadas.^6. Execute o simulador interagindo com diferentes operações.',
    '/* Implemente as funções e o simulador aqui */',
     160, 15, 3);


INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (13, 'Switch case',
    'A estrutura switch-case é um tipo de controle de fluxo em muitas linguagens de programação, incluindo JavaScript. Ela é utilizada quando você precisa fazer uma escolha entre várias opções ou casos.',
    'Desafio do Exercício 14',
    '1. Explique a estrutura básica do switch-case e quando ela é útil.^2. Implemente um exemplo prático usando switch-case para fazer uma escolha entre diferentes casos.^3. Execute o código e observe o resultado.^4. Comente sobre as vantagens e desvantagens do uso de switch-case.',
    '/* Implemente o exemplo prático aqui */',90, 8, 3);


INSERT INTO exercicio
     (num_exercicio, titulo, conteudo_teorico, desafio, instrucao, layout_funcao, xp, moeda, fase_id)
VALUES
    (14, 'Switch case',
    'O programa recebe um número de 1 a 7, onde cada número representa um dia da semana. Usando a estrutura switch-case, determina e exibe o dia correspondente.',
    'Desafio do Exercício 15',
    '1. Captura do Número do Usuário: Use o prompt para solicitar um número ao usuário.^2. Switch-Case: Use a estrutura switch-case para determinar o dia da semana com base no número inserido.^3. Resultado: Exiba o resultado para o usuário.^4. Teste o programa com diferentes números para garantir que está funcionando corretamente.',
    '/* Implemente o programa aqui */',100, 8, 3);