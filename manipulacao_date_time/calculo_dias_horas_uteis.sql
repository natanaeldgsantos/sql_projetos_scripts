/*

Exemplo de código para cálculo da diferença em horas úteis entre duas datas (datetime) considerando:
. Horário de Inicio do Expediente
. Saída para Almoço (intervalo)
. Retorno do Almoço (intervalo)
. Horário de Término do Expediente

Script para MS SQL Server, em T-SQL


*/


DECLARE @DtHrAbertura   DATETIME,
        @DtHrFechamento DATETIME,
        @HrEntrada		TIME,
        @HrSaida		TIME, 
        @HrInicioAlmoco	TIME,
        @HrFimAlmoco	TIME
 
SELECT @DtHrAbertura    = '2014-04-21 12:00:00',
       @DtHrFechamento  = '2014-04-22 17:30:00',
       @HrEntrada		= '09:00:00',
       @HrSaida			= '18:00:00',
       @HrInicioAlmoco	= '12:00:00',
       @HrFimAlmoco		= '13:00:00'
 
 
-- Popular tabela temporária para filtrar o resultado
DECLARE @tbTempoAtendimento AS TABLE (Data DATETIME)
 
WHILE @DtHrAbertura <= @DtHrFechamento BEGIN
      IF (	 CAST(@DtHrAbertura AS TIME) BETWEEN  @HrInicioAlmoco AND  @HrFimAlmoco -- Ignorar Horario de Almo�o
          OR DATEPART(WEEKDAY,@DtHrAbertura) in (7,1) -- Ignorar Sabado e Domingo
          OR CAST(@DtHrAbertura AS TIME) NOT BETWEEN  @HrEntrada AND  @HrSaida -- Ignorar Horarios Fora de Expediente
          )
	      SET @DtHrAbertura = DATEADD(MINUTE, 1, @DtHrAbertura)
	  ELSE BEGIN
		INSERT @tbTempoAtendimento SELECT @DtHrAbertura    
		SET @DtHrAbertura = DATEADD(MINUTE, 1, @DtHrAbertura)		
	  END
END
 
-- Resultado Total de Hrs trabalhadas
SELECT 
      HrsTrabalhadas = DATEADD(mi, (COUNT(Data)/Cast(60 as decimal(4,2)) - FLOOR(COUNT(Data)/Cast(60 as decimal(4,2)))) * 60, DATEADD(hh, FLOOR(COUNT(Data)/Cast(60 as decimal(4,2))), CAST ('00:00:00' AS TIME)))
FROM
      @tbTempoAtendimento

 
-- Resultado por Dia de Hrs trabalhadas
SELECT 
    [Dia] = CASE DATEPART(WEEKDAY,CAST(Data AS DATE))
            WHEN 1 THEN 'Domingo'
            WHEN 2 THEN 'Segunda-feira'
            WHEN 3 THEN 'Ter�a-feira'
            WHEN 4 THEN 'Quarta-feira'
            WHEN 5 THEN 'Quinta-feira'
            WHEN 6 THEN 'Sexta-feira'
            WHEN 7 THEN 'S�bado'      END,
      [Entrada] = MIN(Data),
      [Sa�da]   = MAX(Data),
      [HrsTrabalhadas] = DATEADD(mi, (COUNT(Data)/Cast(60 as decimal(4,2)) - FLOOR(COUNT(Data)/Cast(60 as decimal(4,2)))) * 60, DATEADD(hh, FLOOR(COUNT(Data)/Cast(60 as decimal(4,2))), CAST ('00:00:00' AS TIME)))
FROM
      @tbTempoAtendimento
GROUP BY
      CAST(Data AS DATE)