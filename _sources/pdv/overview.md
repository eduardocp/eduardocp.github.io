Visão geral
============================

Existem alguns tipos de PDV's:

* [Desktop](#desktop)
* [Mobile](#mobile)
* [Vending Machine](#vending-machine)
* [POS Fixo](#pos-fixo-e-movel)
* [POS Móvel](#pos-fixo-e-movel)

## Desktop

Esse PDV opera quase 100% apenas com teclado por teclas de atalho.  
Possui uma base de dados off-line que permite que mesmo sem conexão, vendas sejam realizadas. Após a conexão com o servidor ser detectada novamente, os dados gerador no modo off-line são sincronizados.  
Atualmente pode ser instalado em:

* Qualquer desktop com Windows XP ou superior, com .NET 4 instalado. (XP deixará de funcionar em breve 🙌)

Nesse PDV podemos:

* [Gerenciar cartão de consumo](#gerenciar-cartao-de-consumo)
* [Gerenciar mesas e comandas](#gerenciar-mesas-e-comandas)
* [Operações de venda](#operacoes-de-venda)
* [Operações de caixa](#operacoes-de-caixa)
* [Acessar menu administrativo do SiTef](#acessar-menu-administrativo-do-sitef)
* [Produtos retornáveis](#produtos-retornaveis)
* [Estacionamento](#estacionamento)
* [Modo Buffet](#modo-buffet)
* [Consumo de voucher](#consumo-de-voucher)
* [Relatório de vendas](#relatorio-de-vendas)

### Gerenciar cartão de consumo

Dentre as funcionalidades com cartões de consumo temos:

* Consulta de saldo
* Ativação de cartão
* Recarga de cartão
* Pagamento de pós-pago
* Devolução de crédito
* Perda de cartão
* Transferência de crédito
* Estorno
* Extrato de conta
* Extrato de consumo
* Pagamento de lote
* Emissão de documento fiscal (fechamento de pré-venda ou checkout)

### Gerenciar mesas e comandas	

Dentre as funcionalidades com mesas e comandas temos:

* [Abrir uma mesa/comanda](#abrir-uma-mesa-comanda)
* [Renomear mesa/comanda](#renomear-mesa-comanda)
* [Informar o número de pessoas](#informar-o-numero-de-pessoas)
* [Juntar mesas](#juntar-mesas)
* [Transferir item](#transferir-item)
* [Identificar/alterar cliente](#identificar-alterar-cliente)
* [Mudar usuário de abertura](#mudar-usuario-de-abertura)
* [Imprimir conferência](#imprimir-conferencia)
* [Imprimir comandas em aberto](#imprimir-comandas-em-aberto)

#### Abrir uma mesa/comanda

Inicia uma mesa/comanda com um nome (numérico ou alfanumérico) no sistema.

#### Renomear mesa/comanda

Muda o nome dado na abertura de uma mesa/comanda.

#### Informar o número de pessoas

Adiciona/altera o número de pessoas que compõem a mesa/comanda.  
Utilizado para rateio de valores na hora do pagamento (somente uma informação, não é considerada para nada).

#### Juntar mesas

Une duas mesas/comandas, enviando todos os itens da mesa/comanda 1 para a mesa/comanda 2.  
Caso tenha identificado o cliente ou informado o número de pessoas na mesa 1, essas informações serão perdidas.

#### Transferir item

Transfere o item de uma mesa/comanda para outra.

#### Identificar/alterar cliente

Caso a mesa/comanda não tenha sido identificada, é possível informar um cartão que seja de sócio.  
Caso já tenha sido informado, é possível alterá-lo.  
A identificação do cliente é utilizada para evitar que sócios saiam pagar os itens consumidos.  

#### Mudar usuário de abertura

Muda o usuário que realizou a abertuar da mesa/comanda.

#### Imprimir conferência

Imprime os itens consumidos junto com suas taxas e descontos para conferência.

#### Imprimir comandas em aberto

Imprime para o operador todas as comandas/mesas que ainda não foram pagas.

### Operações de venda

Nesse PDV o procedimento de venda é gravado passo a passo para que, caso a aplicação seja encerrada, ao reiniciá-la, seja retomado do ponto em que o operador parou.

Uma venda pode ser do tipo:

* Venda (tipo padrão)
* NFe (utilizado para homologação do PAF [desativado atualmente])
* Pré-venda (seu documento fiscal não foi emitido)
* CCF (originada da emissão de documentos fiscais de vendas que são do tipo `Pré-venda`)
* Venda manual (realizada através do `Retaguarda`)
* Venda de ingressos (integração com o `MultiClubes` para liberação de acesso)
* Venda temporária (deixará de existir ao final do precesso em questão)

Dentre as funcionalidades com vendas temos:

* [Localizar um produto](#localizar-um-produto)
* [Realizar uma venda](#realiza-uma-venda)
* [Cancelar última venda](#cancelar-ultima-venda)
* [Cancelar uma venda que tenha emitido documento fiscal](##cancelar-uma-venda-que-tenha-emitido-documento-fiscal)
* [Realizar checkout](#realizar-checkout)
* [Imprimir segunda via de documento fiscal](#imprimir-segunda-via-de-documento-fiscal)

#### Localizar um produto

Localiza um produto por código ou nome.

#### Realiza uma venda

Após digitar o código de um produto e aperta `ENTER`, uma venda é inicializada.

Aqui podemos:

* [Inserir outros produtos](#inserir-outros-produtos)
* [Cancelar a venda](#cancelar-a-venda)
* [Cancelar um item](#cancelar-um-item)
* [Aplicar descontos](#aplicar-descontos)
* [Cancelar descontos](#cancelar-descontos)
* [Cancelar taxas de acréscimos](#cancelar-taxas-de-acrescimos)
* [Identificar/alterar/remover o consumidor](#identificar-alterar-remover-o-consumidor)
* [Realizar pagamentos](#realizar-pagamentos)
  * [Pagamento único](#pagamento-unico)
  * [Pagamento múltiplo](#pagamento-multiplo)

Ao final da operação, será impresso o resumo da venda, comprovante de pagamento e, caso seja possível, um documento fiscal (NFC-e, SAT ou ECF, NFS-e).  

##### Inserir outros produtos

Para inserir um produto, podemos usar a busca de produtos ou digitar diretamente o código do produto.

Também podemos realizar multiplicações para inserir peso ou quantidade de um produto (essa funcionalidade também se aplica na inicialização da venda):

* Quando o produto não é fracionável, podemos digitar a quandidade desejada, seguida de 'x', seguido do código do produto.

```{admonition} Exemplo
3 x 1234
```

* Quando o produto é fracionável, podemos digitar seu peso, seguida de 'x', seguido do código do produto.

```{admonition} Exemplo
0,648 x 1234
```

Após o sistema identificar o produto, serão aplicados os acréscimos e descontos pertinentes.

Quando o produto é um produto retornável (aluguel), é necessário informar um identificador para esse produto para quando ele for devolvido.

```{admonition} Exemplo
Produtos retornáveis são comuns para aluguel de armários, onde o cliente fica com a chave e quando não precisa mais devolve.
```

Quando o produto está configurado para imprimir em um local, após a realização do pedido, é realizada a impressão desse produto nos locais configurados.

##### Cancelar a venda

Cancela a venda que está em andamento.  
Caso tenha informado algum pagamento em cartão de crédito/débito, essa transação é desfeita.

##### Cancelar um item

Marca o item como cancelado.  
O item é enviado ao servidor para que a venda seja registrada exatamente como foi feita no PDV.

##### Aplicar descontos

Aplica desconto ao valor da venda.  
Caso algum item tenha desconto individual, o mesmo será desconsiderado.

##### Cancelar descontos

Remove o desconto de produtos que tenham desconto individual.

##### Cancelar taxas de acréscimos

Remove uma ou todas as taxas de acréscimos envolvidas na venda.

##### Identificar/alterar/remover o consumidor

Altera os dados do consumidor que será enviado para o documento fiscal.

##### Realizar pagamentos

###### Pagamento único

Realiza o pagamento com o valor total da venda de acordo com a forma de pagamento escolhida.

###### Pagamento múltiplo

Caso a primeira forma de pagamento seja `Cartão de consumo`, o restante do valor deverá ser recebido também em `Cartão de consumo`.  
As demais formas de pagamento permite serem misturadas.  

#### Cancelar última venda

O sistema cancela a última venda realizada, estorna o pagamento e cancela o documento fiscal (caso tenha algum emitido).  
Caso tenha algum motivo de cancelamento no sistema, será pedido que escolha um; se houver somente um, será escolhido automaticamente.  
Caso esse motivo de cancelamento precise de justificativa, será pedido ao usuário que informe uma.

#### Cancelar uma venda que tenha emitido documento fiscal

Exibe uma lista de vendas que emitiram documento fiscal para ser cancelada.

Após a escolha da venda, realiza o mesmo processo de `Cancelar última venda`.

#### Realizar checkout

Ao entrar no modo checkout, é solicitado o(s) cartão(ões) que fará(ão) parte da operação.  

Ao informar um cartão, exibido o extrato do mesmo, para conferência.  

Após a confirmação, esse cartão é adicionado ao processo.  

Ao finalizar a inserção dos cartões, o PDV inicia uma venda do tipo temporária que será convertida em uma venda CCF ao final do processo.  

Nesse momento, o operador pode cancelar descontos, o cliente pode contestar alguma taxa de acréscimo e pode ser vendidos novos itens.  

O modo soma todas as taxas de acréscimos e todos os descontos envolvidos e informa ao operador juntamente com o total.  

Caso todos os documentos fiscais já tenham sido emitidos, o cliente deverá somente pagar o valor devido do contrário, os documentos fiscais também serão emitidos.  

Produtos que são do tipo serviço, serão emitidos pelo serviço do MultiClubes como NFS-e, já os demais produtos, serão emitidos pelo MultiVendas como NFC-e ou SAT.

Após todo o procedimento ser realizado no servidor, as impressões começam a serem feitas (documentos fiscais, comprovantes de pagamentos, etc).  

```{admonition} Nota
Caso algum passo antes da impressão apresente algum erro, o processo é interrompido e nada é registrado.

Caso algum erro na impressão seja apresentado, o processo continua, pois podemos recuperar essa impressão posteriormente.
```

#### Imprimir segunda via de documento fiscal

Exibe uma lista de documentos fiscais que já foram emitidos.

Imprime a segunda via do documento.

### Operações de caixa

Dentre as funcionalidades com caixa temos:

* [Bloquear o PDV](#bloquear-o-pdv)
* [Suprimento (entrada de valor)](#suprimento)
* [Sangria (saída de valor)](#sangria)
* [Fechamento](#fechamento)
* [Solicitar troca de senha](#solicitar-troca-de-senha)

#### Bloquear o PDV

Volta o PDV para a tela de login.

Pode ser liberado apenas com o mesmo login que bloquou ou um usuário que tenha permissão para fazer o processo.

#### Suprimento

Realiza um movimento de caixa de entrada de dinheiro utilizando o usuário e senha com o valor em dinheiro informado no processo.

Pode ser cancelado ao pressionar `ESC`.

#### Sangria

Realiza um movimento de caixa de saída de dinheiro utilizando o usuário e senha com o valor em dinheiro informado no processo.

Pode ser cancelado ao pressionar `ESC`.

#### Fechamento

Realiza fechamento do caixa utilizando o usuário e senha com o valor de dinheiro em caixa informado no processo.

Pode ser cancelado ao pressionar `ESC`.

#### Solicitar troca de senha

Realiza a troca da senha do usuário informado.

A senha só entrará em vigor após `Atualiza pontos de vendas` no Retaguarda.

Pode ser cancelado ao pressionar `ESC`.

### Acessar menu administrativo do SiTef

???? verificar com alguem que está com pinpad

### Produtos retornáveis

Nessa funcionalidade, podemos registrar a devolução do produto, podendo ter valor a pagar ou a devolver (de acordo com as configurações do produto).

### Estacionamento

Nessa funcionalidade, podemos realizar o pagamentos de um ticket de estacionamento.

### Modo Buffet

Esse modo foi desenvolvido para situações onde envolvam balança.  

É uma maneira rápida de registrar um produto configurado por uma unidade de medida pesada em um cartão de consumo.  

Pode ser configurado com duas balanças para situações onde é comum ter dois produtos pesados como self-service comum e comida japonesa, ou sobremesa, etc.

O modo já inicia com um produto selecionado, caso precise trocar, é só clicar em cima do produto e selecionar outro.  

Após entrar nesse modo, o PDV fica aguardando a balança enviar um peso para o PDV.  

Após receber esse valor, o cartão de consumo precisa ser passado no leitor configurado.

O modo fica ativo o tempo todo repetindo esse fluxo, até o operador encerrar pressionando `ESC`.

### Consumo de voucher

Esse modo foi desenvolvido para situações de rápido consumo de um produto do tipo voucher.  
Após entrar nesse modo, é solicitado qual regra deseja aplicar ao modo.  
Após a escolha da regra, o PDV fica aguardando um cartão de consumo ser informado.  
O modo fica ativo o tempo todo repetindo esse fluxo, até o operador encerrar pressionando `ESC`.

### Relatório de vendas

Nessa funcionalidade, podemos exibir todos os protudos vendidos, no PDV em questão ou em todos os PDV's (caso o usuário tenha permissão), no período indicado.

## Mobile

Esse PDV opera 100% online possuindo uma base de dados off-line apenas para consulta.  
Não havendo conexão, não há como realizar operações.  
Atualmente pode ser instalado em:

* Qualquer dispositivo Android 4.4 ou superior
* Gertec GPOS700
* Cielo LIO

Nesse PDV podemos:

* [Gerenciar cartão de consumo](gerenciar-cartao-de-consumo-mobile)
* [Gerenciar mesas e comandas](gerenciar-mesas-e-comandas-mobile)
* [Operações de venda](operacoes-venda-mobile)
* [Realizar estorno](realizar-estorno-mobile)
* [Consumo de voucher](consumo-voucher-mobile)
* [Relatório de vendas](relatorio-venda-mobile)

(gerenciar-cartao-de-consumo-mobile)=
### Gerenciar cartão de consumo 

Dentre as funcionalidades com cartões de consumo temos:

* [Recarga de cartão](recarga-de-cartao-mobile)
* [Pagamento de pós-pago](pagamento-de-pos-pago-mobile)
* [Extrato (conta e consumo)](extrato-mobile)
* [Impressão do extrato (conta e consumo)](impressao-extrato-mobile)

(recarga-de-cartao-mobile)=
#### Recarga de cartão

Adiciona crédito ao cartão.

(pagamento-de-pos-pago-mobile)=
#### Pagamento de pós-pago

Realiza o pagamento dos movimentos em aberto do cartão.

(extrato-mobile)=
#### Extrato (conta e consumo)

Exibe os itens vendidos, recargas/pagamentos, transferências e estornos do cartão no período escolhido juntamente com detalhes de saldo disponível.

(impressao-extrato-mobile)=
#### Impressão do extrato (conta e consumo)

É impresso separadamente o resumo do extrato da conta ou dos consumos (dependendo de qual funcionalidade escolher) no período escolhido.

(gerenciar-mesas-e-comandas-mobile)=
### Gerenciar mesas e comandas 

Dentre as funcionalidades com mesas e comandas temos:

* [Iniciar mesa/comanda](iniciar-mesa-comanda-mobile)
* [Renomear mesa/comanda](renomear-mesa-comanda-mobile)
* [Informar o número de pessoas](informar-o-numero-de-pessoas-mobile)
* [Imprimir conferência](imprimir-conferencia-mobile)
* [Bloquear mesa/comanda](bloquear-mesa-mobile)
* [Identificar/alterar o cliente](identificar-alterar-o-cliente-mobile)

(iniciar-mesa-comanda-mobile)=
#### Iniciar mesa/comanda

Inicia uma mesa/comanda com um nome (numérico ou alfanumérico) no sistema.

(renomear-mesa-comanda-mobile)=
#### Renomear mesa/comanda

Muda o nome dado na abertura de uma mesa/comanda.

(informar-o-numero-de-pessoas-mobile)=
#### Informar o número de pessoas

Adiciona/altera o número de pessoas que compõem a mesa/comanda.  
Utilizado para rateio de valores na hora do pagamento (somente informativo).

(imprimir-conferencia-mobile)=
#### Imprimir conferência

Imprime os itens consumidos junto com suas taxas e descontos para conferência.

(bloquear-mesa-mobile)=
#### Bloquear mesa/comanda

Bloqueia a mesa/comanda evitando que novos itens sejam lançados.  
Utilizado para fechar a comanda.  

(identificar-alterar-o-cliente-mobile)=
#### Identificar/alterar o cliente

Caso a mesa/comanda não tenha sido identificada, é possível informar um cartão que seja de sócio.  
Caso já tenha sido informado, é possível alterá-lo.  
A identificação do cliente é utilizada para evitar que sócios saiam pagar os itens consumidos.  

(operacoes-venda-mobile)=
### Operações de venda

Nesse PDV as vendas só são enviadas ao servidor ao final da operação.  
Se por algum motivo, a aplicação é encerrada no meio do processo, nada é enviado.  
Caso o cliente já tenha informado algum pagamento por cartão de crédito/débito, ao reiniciar a aplicação, essas transações são desfeitas.

Uma venda pode ser do tipo:

* Venda (tipo padrão)
* Pré-venda (seu documento fiscal não foi emitido)

Dentre as funcionalidades com vendas temos:

* [Localizar um produto](#localizar-um-produto)
* [Realizar uma venda](#realiza-uma-venda)

#### Localizar um produto

Localiza um produto por código ou nome.

#### Realiza uma venda

Após digitar o código de um produto e aperta `ENTER`, uma venda é inicializada.

Aqui podemos:

* [Inserir outros produtos](#inserir-outros-produtos)
* [Cancelar a venda](#cancelar-a-venda)
* [Cancelar um item](#cancelar-um-item)
* [Aplicar descontos](#aplicar-descontos)
* [Cancelar descontos](#cancelar-descontos)
* [Cancelar taxas de acréscimos](#cancelar-taxas-de-acrescimos)
* [Identificar/alterar/remover o consumidor](#identificar-alterar-remover-o-consumidor)
* [Realizar pagamentos](#realizar-pagamentos)
  * [Pagamento único](#pagamento-unico)
  * [Pagamento múltiplo](#pagamento-multiplo)

Ao final da operação, será impresso o resumo da venda, comprovante de pagamento e, caso seja possível, um documento fiscal (NFC-e).  

```{admonition} Nota
Nesse PDV o cupom é impresso na sua forma compacta devido à largura do papel que as impressoras bluetooth usam.
```

##### Inserir outros produtos

Para inserir um produto, podemos usar a busca de produtos ou digitar diretamente o código do produto.

Também podemos realizar multiplicações para inserir peso ou quantidade de um produto (essa funcionalidade também se aplica na inicialização da venda):

* Quando o produto não é fracionável, podemos digitar a quandidade desejada, seguida de 'x', seguido do código do produto.

```{admonition} Exemplo
3 x 1234
```

* Quando o produto é fracionável, podemos digitar seu peso, seguida de 'x', seguido do código do produto.

```{admonition} Exemplo
0,648 x 1234
```

Após o sistema identificar o produto, serão aplicados os acréscimos e descontos pertinentes.

Quando o produto é um produto retornável (aluguel), é necessário informar um identificador para esse produto para quando ele for devolvido.

```{admonition} Exemplo
Produtos retornáveis são comuns para aluguel de armários, onde o cliente fica com a chave e quando não precisa mais devolve.
```

Quando o produto está configurado para imprimir em um local, após a realização do pedido, é realizada a impressão desse produto nos locais configurados.

##### Cancelar a venda

Cancela a venda que está em andamento.  
Caso tenha informado algum pagamento em cartão de crédito/débito, essa transação é desfeita.

##### Cancelar um item

Marca o item como cancelado.  
O item é enviado ao servidor para que a venda seja registrada exatamente como foi feita no PDV.

##### Aplicar descontos

Aplica desconto ao valor da venda.  
Caso algum item tenha desconto individual, o mesmo será desconsiderado.

##### Cancelar descontos

Remove o desconto de produtos que tenham desconto individual.

##### Cancelar taxas de acréscimos

Remove uma ou todas as taxas de acréscimos envolvidas na venda.

##### Identificar/alterar/remover o consumidor

Altera os dados do consumidor que será enviado para o documento fiscal.

##### Realizar pagamentos

###### Pagamento único

Realiza o pagamento com o valor total da venda de acordo com a forma de pagamento escolhida.

###### Pagamento múltiplo

Caso a primeira forma de pagamento seja `Cartão de consumo`, o restante do valor deverá ser recebido também em `Cartão de consumo`.  
As demais formas de pagamento permite serem misturadas.  

(realizar-estorno-mobile)=
### Realizar estorno 

A funcionalidade permite cancelar vendas que possuem seu documento fiscal emitido no mesmo dia.  
A venda não pode fazer parte de um cartão que já tenha feito checkout ou já tenha sido encerrado.

(consumo-voucher-mobile)=
### Consumo voucher 

Esse modo foi desenvolvido para situações de rápido consumo de um produto do tipo voucher.  
Após entrar nesse modo, é solicitado qual regra deseja aplicar ao modo.  
Após a escolha da regra, o PDV fica aguardando um cartão de consumo ser informado.  
O modo fica ativo o tempo todo repetindo esse fluxo, até o operador encerrar pressionando o botão de `Voltar` do dispositivo.

(relatorio-venda-mobile)=
### Relatório de vendas 

Nessa funcionalidade, podemos exibir todos os protudos vendidos, no PDV em questão ou em todos os PDV's (caso o usuário tenha permissão), no período indicado.


## Vending Machine

Vending Machines são aquelas máquinas com produtos dentro onde você coloca uma nota de dinheiro e escolhe qual produto quer.  
No caso do MultiVendas, essas máquinas consultam o cartão de consumo para saber podem liberar o produto.  

## POS fixo e móvel

São compostodos de um visor, teclado, leitor de cartão de tarja magnética e uma impressora imbutida.  
Seu sistema operacional e a linguagem utilizada são antigos e não receberam atualizações ao longo do tempo.  
A diferença do fixo para o móvel é que o móvel possui uma placa Wifi que permite sair do local com o equipamento.  

Nesse PDV podemos:

* Realizar vendas
* Estornar a venda 
* Consultar saldo do cartão de consumo
* Consultar produtos

```{admonition} Nota
Nós não temos uma política de End-of-life clara.  
Os POS fixo/móveis não estão mais disponíveis no mercado e nós indicamos o uso do PDV Android.  
Mas existe ainda uma grande quantidade de dispositivos em operação nos clientes, então precisamos manter o suporte, mas evitamos novas funções/melhorias nele.  
```