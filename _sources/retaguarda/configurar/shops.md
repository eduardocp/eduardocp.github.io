Gerenciar as Lojas e suas dependentes
============================

A área de lojas é responsável por listar, cadastrar, editar, excluir e desativar as lojas que estão presentes no sistema.

Nessa área é possível:

* [Listar lojas](#listar-lojas)
* [Alterar dados](#alterar-dados)
* [Gerenciar a estrutura](#gerenciar-a-estrutura)
* [Gerenciar os acréscimos](#gerenciar-acrescimos)
* [Gerenciar as impressoras de rede](#gerenciar-as-impressoras-de-rede)
* [Configurar os PDV's](#configurar-os-pdv-s)
* [Configurar o TEF](#configurar-o-tef)
* [Configurar o NFC-e](#configurar-o-nfc-e)
* [Configurar o SAT](#configurar-o-sat)
* [Configurar o NFS-e](#configurar-o-nfs-e)

## Listar lojas

A tela de listagem mostra todas as lojas cadastradas.

Também é possível filtrar por:

* Lojas ativas
* Nome
* Telefone
* Ramal

## Alterar dados

Na tela de edição da loja podemos alterar várias informações da loja, dentre ela temos: 

* Alterar dados básicos
* Alterar dados contábeis
* Alterar dados de contato
* Alterar endereços

Essas informações são necessárias para a parte tributária.

## Gerenciar a estrutura

As lojas são divididas em dois tipos:

* **Loja Completa**
		
	* São as lojas que possuem CNPJ próprio
	* Podem ou não serem relacionadas a outra loja completa
	* Emitem documentos fiscais
	* Realizam integrações
	* Possuem estoque
	* Possuem locais de impressão

* **Loja Simples**

	* São lojas que não possuem CNPJ
	* Dependem de uma loja completa para emissão de todos documento fiscal (NFC-e ou SAT, NFS-e podem emitir)
	* Possuem estoque
	* Possuem locais de impressão

A estrutura das lojas é bem ampla.  
Cada loja pode ter como filha outras lojas (simples ou completa) e PDV's.

**Ex. 1.)**

1. Loja Completa 1
   1. PDV 1.1
   1. PDV 1.2
   1. Loja Simples 1.1
      1. PDV 1.1.1
      1. PDV 1.1.2
   1. Loja Completa 2
      1. Loja simples 2.1
	  1. Loja simples 2.2
    
**Ex. 2.)**

1. Loja Completa 1
   1. PDV 1.1
   1. PDV 1.2
   1. Loja Simples 1.1
1. Loja Completa 2
   1. PDV 2.1
   1. PDV 2.2
   1. Loja simples 2.1
   1. Loja simples 2.2

## Gerenciar acréscimos

Cada loja tem autonomia para definir quais acréscimos serão considerados no momento de venda.

## Gerenciar as impressoras de rede

Cada loja pode informar impressoras de rede para os locais de pedido cadastrados no sistema.

```{admonition} Ex.

Para o local de pedido: **Cozinha**:

* Loja A:
  * Bematech 4200 no IP 192.168.1.1
* Loja B:
  * Bematech 4000 no IP 192.168.1.152
```

## Configurar os PDV's

Cada loja pode implementar comportamentos específicos para seus PDV's como:

* Identificação de cartão de consumo no ínicio da venda
* Mesas e comandas
  * Se permite utilizar mesa e comanda
  * Configuração dos nomes (somente número ou texto livre)
  * Identificação do cliente na abertura
* Mobile
  * Se permite utilizar mobile
  * Formas de login (NFC ou digitado)
* Configuração do Token do IBPT [^ibpt]

## Configurar o TEF

Caso o sistema esteja configurado para multi-loja, cada loja deverá configurar o código do estabelecimento da loja (de acordo com as configurações do SiTef).  
Também é possível configurar os dados de integração da API da Cielo LIO [^lio] caso o sistema permita transações com ela.

## Configurar o NFC-e

Cada loja completa pode emitir NFC-e.  
Para isso é necessário que o CNPJ possua um certificado válido (do tipo NF-e A1) e o CSC (Código de Segurança do Contribuinte).

## Configurar o SAT

```{admonition} Aviso
:class: warning
**SAT SÓ É UTILIZADO NO ESTADO DE SÃO PAULO**
```

Cada loja completa pode emitir SAT.  
Para isso é necessário informar a assinatura do contribuínte (AC) e o ambiente que utilizará (produção ou homologação).

## Configurar o NFS-e

A emissão da NFS-e é feita pelo MultiClubes.  
Basta só selecionar o provedor que deseja utilizar.

[^ibpt]: IBPT é necssário para cumprir a lei "de olho nos impostos" que pede para imprimir na nota a % de impostos que o consumidor paga sobre a compra
[^lio]: Solução móvel da Cielo que executa aplicativos mobile cadastrados em sua loja.