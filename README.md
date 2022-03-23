# Tracing and Monitoring (FireDAC)
## Monitore instruções SQL usando firedac.

>Requisitos
>> SynEdit https://github.com/SynEdit/SynEdit
>> Firedac Componentes

# Como usar 
Adicionar na conexão da sua aplicação o seguuinte componente
trace: TFDMoniFlatFileClientLink;// Componente

```
    
  Trace.FileName := 'C:\MonitorFiredac\log.txt';
  Trace.Tracing:= True;

```

Tracing and Monitoring (FireDAC)
https://docwiki.embarcadero.com/RADStudio/Alexandria/en/Tracing_and_Monitoring_(FireDAC)

![alt](src/img/Print.png)


O monitoramento se basear em leitura de log via Firedac, disponível em : C:\MonitorFiredac\log.txt

