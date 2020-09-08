Configurar Integrações
============================

O sistema conta com as integrações:

* [MultiClubes](#multiclubes)
* [ERP](#erp)
* [Hotel](#integracao-hotel)
* [Ows](#ows)
* [Onity](#onity)
* [Broker Fiscal](#broker-fiscal)
* [Estacionamento](#estacionamento)
* [PAF](#paf)
* [Micros MyVisitor](#micros-myvisitor)

## MultiClubes

Habilitando as configurações de integração do MultiClubes [^configMultiClubes] podemos integrar os dados de consumo dos sócios.

Para isso, precisamos:

* Configurar o nome da base do MultiClubes e o endereço do serviço OnlineServices.
* Definir a loja padrão que será usada para criação de pré-vendas no acesso dos dispositivos de acesso.
* Configurar a importação de consumo dos clientes do MultiClubes. Todos consumo em aberto dos clientes serão atrelados à cobrança gerada no período em questão. Após esse vínculo, esses consumos não poderão mais ser pagos nos PDV's.

## ERP

Habilitando as configurações de integração do ERP [^configErp] o sistema passará a gerar os dados consolidados necessários para a integração ERP.

Para isso, precisamos:

* Configurar as associações de categorias, centros de custos, formas de pagamentos, etc, utilizados no ERP em questão.

```{admonition} Nota
Essa integração depende da [integração do MultiClubes](#multiclubes)
```

## Integração Hotel

Habilitando as configurações de integração para hotel [^configHotel] permite que serviços externos se comunique com o MultiVendas enviando informações sobre o hóspede, permitindo que o mesmo utilize os recursos de identificação do hotel (cartões, chaves ou n° do quarto) dentro do MultiVendas.

Para habilitar a integração do hotel é preciso configurar:

* Emissão de documento fiscais.
* Impressão de ticket no checkout.
* Mensagens do ticket.
* Lojas que usam a integração do hotel.

```{admonition} Nota
Essa integração depende da [integração do MultiClubes](#multiclubes)
```

### OWS

Checkin
Consulta o Oracle (OWS) e em seguida registra no multivenda

O OWS é o sistema de hotelaria da Oracle.  
Como eles não quiseram realizar a integração pelo lado deles, foi preciso realizar pelo nosso lado.  
O MultiVendas PDV acaba sendo um middleware para a integração entre MultiVendas e OWS.  
Basicamente nossa interface consulta o a api do OWS e utiliza a nossa api de hotel para registrar o hóspede encontrado.

Habilitando as configurações de integração OWS [^configHotelOws] nosso PDV poderá consulta a api do OWS para registrar o hóspede encontrado utilizando a nossa api de hotel.

Para isso, precisamos:

* Configurar o acesso ao serviço
* Configurar o tipo de pagamento
* Configurar o tipo de ativação
* Configurar a sequência de hóspedes
* Configurar os tipos de clientes
* Configurar os vouchers

```{admonition} Nota
Essa integração depende da [integração para Hotel](#integracao-hotel)  
Essa integração depende da integração do Micros MyVistor
```

### Onity

É um sistema de fechaduras funcionando como uma extensão do hotel.

Habilitando as configurações de integração Onity [^configHotelOnity] operações que envolvam ativação poderão integrar com o sistema de fechadura do hotel permitindo gravar a chave e cartão de consumo juntos.

Para isso, precisamos: 

* Fornecer a URL do endereço do serviço
* Configurar o identificador e encoder para cada loja que irá integrar

```{admonition} Nota
Essa integração depende da [integração para Hotel](#integracao-hotel)  
Essa integração depende da [integração do OWS](#ows)
```

## Broker Fiscal

Habilitando as configurações de integração com o Broker Fiscar [^configBrokerFiscal] os documentos fiscais emitidos serão integrados com o serviço escolhido.

Para isso, precisamos: 

* Escolher o serviço (atualmente só existe Complience)
* Fornecer a URL do endereço do serviço
* Configurar o identificador e chave para cada loja que irá integrar


## Estacionamento

Habilitando as configurações de integração com o Estacionamento [^configEstacionamento] permite o PDV consultar tickets em uma base específica e realizar o pagamento desses tickets.???? (verificar pbi 29613? e com o otavio para entender melhor o funcionamento)

## PAF

Habilitando as configurações de integração com o PAF [^configPaf] o PDV pode gerar o arquivos necessários para o PAF ECF.

## Micros MyVisitor

```{admonition} Nota
Essa integração não é mais utilizada (OWS entrou no lugar).  
Só não foi removida pois o trabalho para remover e retestar tudo, não compensa.
```

Habilitando as configurações de integração com o Micros MyVisitor [^configMicros] o sistema passa a consultar o saldo e consumos realizados no cartão através do Micros MyVisitor.

[^configMultiClubes]: Sistema -> Configurações do sistema -> Aba MultiClubes
[^configErp]: Sistema -> Configurações do sistema -> Aba ERP
[^configHotel]: Sistema -> Configurações do sistema -> Aba Integração Hotel
[^configHotelOws]: Sistema -> Configurações do sistema -> Aba Ows
[^configHotelOnity]: Sistema -> Configurações do sistema -> Aba Onity
[^configBrokerFiscal]: Sistema -> Configurações do sistema -> Aba Broker Fiscal
[^configEstacionamento]: Sistema -> Configurações do sistema -> Aba Estacionamento
[^configPaf]: Sistema -> Configurações do sistema -> Aba Estacionamento
[^configMicros]: Sistema -> Configurações do sistema -> Aba Micros MyVisitor