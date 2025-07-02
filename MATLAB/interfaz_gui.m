% GUI Mejorada para Experimento de Caída Libre
function gui_caida_librev7()
    % Crear figura principal
    f = figure('Name','Experimento Caída Libre','Position',[100 100 1000 600]);
    
    try
    resultado = reconocimientoFacial();
    
    % Separa el resultado en estado y nombre
    parts = strsplit(resultado, ':');
    
    if numel(parts) == 2
        estado = parts{1};
        nombre = parts{2};
    else
        estado = '0';
        nombre = '';
    end
    
    if strcmp(estado, '1')
        msgbox(['✅ Rostro verificado. Bienvenido, ', nombre]);
    else
        errordlg('❌ Rostro no reconocido. El programa se cerrará.');
        close(f);
        return;
    end
catch ME
    errordlg(['Error en reconocimiento facial: ' ME.message]);
    close(f);
    return;
end


    % Variables globales
    global s datos alturas tiempos velocidades plotHandle tablaHandle eqText puertoMenu puertoConectado estadoLabel consolaHandle axesHandle;
    datos = [];
    alturas = [];
    tiempos = [];
    velocidades = [];
    puertoConectado = false;

    % --- Agregar Título ---
    uicontrol('Style','text', 'Position',[300 570 400 30], 'String', 'Experimento de Caída Libre', ...
    'FontSize',16, 'FontWeight','bold', 'HorizontalAlignment','left');


    % Elementos GUI
    uicontrol('Style','text','Position',[20 540 100 20],'String','Puerto:');
    puertoMenu = uicontrol('Style','popupmenu','Position',[80 540 100 25],...
        'String',serialportlist,'Callback',@seleccionarPuerto);
    uicontrol('Style','pushbutton','Position',[200 540 100 30],'String','Conectar',...
        'Callback',@conectar);
    estadoLabel = uicontrol('Style','text','Position',[320 540 200 25],'String','Desconectado','ForegroundColor','r');

    uicontrol('Style','pushbutton','Position',[20 500 100 30],'String','Subir','Callback', @(src,event) enviarComando('subir'));
    uicontrol('Style','pushbutton','Position',[140 500 100 30],'String','Bajar','Callback', @(src,event) enviarComando('bajar'));
    uicontrol('Style','pushbutton','Position',[260 500 100 30],'String','Activar','Callback', @(src,event) enviarComando('activar'));
    uicontrol('Style','pushbutton','Position',[380 500 100 30],'String','Desactivar','Callback', @(src,event) enviarComando('desactivar'));

    uicontrol('Style','pushbutton','Position',[500 500 100 30],'String','Iniciar',...
    'Callback', @(src,event) iniciarMedicion(), 'BackgroundColor',[0.2 0.8 0.2]); 

    uicontrol('Style','pushbutton','Position',[600 550 150 25],'String','Resetear',...
    'Callback', @(src,event) resetearSistema(), 'BackgroundColor',[0.8 0.2 0.2]); 

    uicontrol('Style','pushbutton','Position',[780 550 150 25],'String','Control por Voz',...
    'Callback', @(src,event) controlPorVoz(), 'BackgroundColor',[0.6 0.9 1]); % Celeste


    tablaHandle = uitable('Position',[600 250 370 280], 'ColumnName',{'Altura (m)','Tiempo (ms)','Velocidad (m/s)'}, 'Data', {});
    eqText = uicontrol('Style','text','Position',[600 230 370 20],'String','Ecuación: ','HorizontalAlignment','left');
    
    % Crear axes y guardar su handle
    axesHandle = axes('Units','pixels','Position',[50 100 500 300]);
    plotHandle = plot(nan, nan, 'bo');
    title('Altura vs Tiempo'); xlabel('Tiempo (ms)'); ylabel('Altura (m)'); grid on;

    consolaHandle = uicontrol('Style','listbox', 'Position',[600 20 370 120], 'String', {}, 'Max', 2, 'Min', 0);

    uicontrol('Style','pushbutton','Position',[600 180 120 30],'String','Exportar Excel','Callback', @(src, event) exportarExcel());
    uicontrol('Style','pushbutton','Position',[750 180 120 30],'String','Generar Reporte','Callback', @(src, event) generarReporte());

    function seleccionarPuerto(src,~)
        puertoSeleccionado = src.String{src.Value};
        assignin('base','puertoSeleccionado',puertoSeleccionado);
    end

    function conectar(~,~)
        puertos = serialportlist;
        if isempty(puertos)
            errordlg('No hay puertos disponibles'); return;
        end
        try
            if puertoConectado, clear s; puertoConectado = false; end
            opciones = puertoMenu.String;
            if ischar(opciones), opciones = cellstr(opciones); end
            puerto = opciones{puertoMenu.Value};
            s = serialport(puerto, 9600);
            configureTerminator(s, "LF"); flush(s); pause(2);
            puertoConectado = true;
            estadoLabel.String = 'Conectado'; estadoLabel.ForegroundColor = 'green';
            logConsola(['✔️ Conectado al puerto: ' puerto]);
        catch ME
            errordlg(['No se pudo conectar: ' ME.message]);
            logConsola(['❌ Error al conectar: ' ME.message]);
        end
    end

    function enviarComando(comando)
        if puertoConectado
            writeline(s, comando);
            logConsola(['➡️ Enviado: ' comando]);
        else
            errordlg('Puerto no conectado');
        end
    end

    function iniciarMedicion()
        if ~puertoConectado, errordlg('Puerto no conectado'); return; end

        % Animación cuenta regresiva
        %for i = 3:-1:1
        %    estadoLabel.String = sprintf('Iniciando en... %d', i);
        %    pause(1);
        %end
        estadoLabel.String = 'Midiendo...';

        writeline(s, 'iniciar');
        logConsola('🟡 Comando "iniciar" enviado...');
        pause(7);

        respuesta = "";
        while s.NumBytesAvailable > 0
            linea = readline(s);
            logConsola(['⬅️ Recibido: ' char(linea)]);
            if contains(linea, 'Tiempo')
                respuesta = linea;
                break;
            end
        end

        if isempty(respuesta), errordlg('No se recibió respuesta'); return; end
        tiempo = sscanf(respuesta, 'Tiempo transcurrido: %d ms');
        if isempty(tiempo) || ~isscalar(tiempo), errordlg('Tiempo inválido'); return; end

        alturaInput = inputdlg('Ingresa altura en metros:','Altura',1);
        if isempty(alturaInput), return; end
        altura = str2double(alturaInput{1});
        if isnan(altura), errordlg('Altura inválida'); return; end

        velocidad = altura / (tiempo / 1000);
        alturas(end+1) = altura;
        tiempos(end+1) = tiempo;
        velocidades(end+1) = velocidad;
        datos = [datos; altura, tiempo, velocidad];

        actualizarTabla(); actualizarGrafico(); actualizarEcuacion();

        if length(alturas) >= 10
            choice = questdlg('¿Deseas guardar los datos?', 'Guardar', 'Sí', 'No', 'No');
            if strcmp(choice, 'Sí'), exportarExcel(); end
        end
    end

    function actualizarTabla()
        tablaHandle.Data = [alturas', tiempos', velocidades'];
    end

function actualizarGrafico()
    % Verificar si plotHandle existe y es válido
    if ~ishandle(plotHandle) || ~isvalid(plotHandle)
        % Recrear el plot si no existe
        axes(axesHandle); % Asegurar que estamos en los axes correctos
        plotHandle = plot(nan, nan, 'bo');
        title('Altura vs Tiempo'); xlabel('Tiempo (ms)'); ylabel('Altura (m)'); grid on;
    end
    
    if isempty(tiempos) || isempty(alturas)
        set(plotHandle, 'XData', nan, 'YData', nan);
        return;
    end

    % Cambiar a los axes correctos antes de hacer el plot
    axes(axesHandle);
    
    % Limpiar el axes y recrear todo
    cla(axesHandle);
    
    % Plot datos
    plotHandle = plot(tiempos, alturas, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    hold on;

    % Solo calcular y graficar regresión si hay 2 o más puntos
    if length(alturas) >= 2
        % Ajuste lineal
        [p,S] = polyfit(tiempos, alturas, 1);

        % Predicción de valores
        xfit = linspace(min(tiempos), max(tiempos), 100);
        yfit = polyval(p, xfit);

        % Intervalo de confianza (evitar error si no hay grados de libertad)
        if isfield(S, 'R') && ~isempty(S.R)
            [yPred, delta] = polyconf(p, xfit, S, 'alpha', 0.05, 'predopt', 'curve');
            % Curva y sombra
            fill([xfit fliplr(xfit)], [yPred+delta fliplr(yPred-delta)], [0.9 0.9 1], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
        end

        % Curva de regresión
        plot(xfit, yfit, 'r-', 'LineWidth', 2);

        % Etiquetas de puntos (opcional)
        for i = 1:length(tiempos)
            text(tiempos(i), alturas(i), sprintf('(%.1f, %.1f)', tiempos(i), alturas(i)), 'FontSize', 8, 'Color', 'k');
        end

        legend('Datos','Intervalo confianza','Regresión','Location','best');
    else
        legend('Datos','Location','best');
    end

    title('Altura vs Tiempo'); 
    xlabel('Tiempo (ms)'); 
    ylabel('Altura (m)'); 
    grid on;
    hold off;
end

    function actualizarEcuacion()
        if length(alturas) >= 2
            p = polyfit(tiempos, alturas, 1);
            eqText.String = sprintf('Ecuación: y = %.4f x + %.4f', p(1), p(2));
        else
            eqText.String = 'Ecuación: ';
        end
    end

    function resetearSistema()
        datos = [];
        alturas = [];
        tiempos = [];
        velocidades = [];
        tablaHandle.Data = {};
        
        % Limpiar axes pero mantener la estructura
        axes(axesHandle);
        cla(axesHandle);
        
        % Recrear el plot
        plotHandle = plot(nan, nan, 'bo');
        title('Altura vs Tiempo'); 
        xlabel('Tiempo (ms)'); 
        ylabel('Altura (m)'); 
        grid on;
        
        eqText.String = 'Ecuación: ';
        logConsola('🔄 Sistema reseteado');
    end

    function exportarExcel(~,~)
        T = table(alturas', tiempos', velocidades', 'VariableNames',{'Altura','Tiempo','Velocidad'});
        filename = ['experimento_',datestr(now,'yyyymmdd_HHMMSS'),'.xlsx'];
        writetable(T, filename);
        msgbox(['Datos guardados en ', filename]);
        logConsola(['📂 Datos exportados a: ' filename]);
    end

    function generarReporte(~,~)
        fReporte = figure('Name','Reporte','Position',[300 300 600 400]);
        uitable(fReporte,'Data',[alturas', tiempos', velocidades'],'ColumnName',{'Altura','Tiempo','Velocidad'},'Position',[50 100 500 250]);
        if length(alturas) >= 2
            p = polyfit(tiempos, alturas, 1);
            uicontrol('Style','text','Position',[50 50 500 30],...
                'String',sprintf('Ecuación regresión: y = %.4f x + %.4f', p(1), p(2)), 'FontSize',12);
        end
    end

    function logConsola(texto)
        anterior = consolaHandle.String;
        if ischar(anterior), anterior = {anterior};
        elseif isstring(anterior), anterior = cellstr(anterior);
        elseif isnumeric(anterior), anterior = {num2str(anterior)};
        elseif isempty(anterior), anterior = {};
        elseif ~iscellstr(anterior), anterior = {char(anterior)};
        end
        nuevaLinea = ['[' datestr(now,'HH:MM:SS') '] ' texto];
        consolaHandle.String = [anterior; {nuevaLinea}];
        if numel(anterior) > 100
            consolaHandle.String = consolaHandle.String(end-99:end);
        end
        % Hacer scroll automático hacia abajo
        consolaHandle.Value = length(consolaHandle.String);
    end

    set(f, 'CloseRequestFcn', @cerrarAplicacion);
    function cerrarAplicacion(~,~)
        if puertoConectado
            writeline(s, "desactivar"); delete(s); clear s;
            logConsola('🔌 Conexión serial cerrada.');
        end
        delete(gcf);
    end
    % Función NUEVA: controlPorVoz
    function controlPorVoz()
        if ~puertoConectado
            errordlg('Puerto no conectado');
            return;
        end

        logConsola('🎤 Grabando audio durante 3 segundos...');
        
        % Archivo temporal para guardar grabación
        archivoAudio = fullfile(tempdir, 'grabacion_filtrada.wav');
        
        % Grabar audio desde micrófono 3 segundos
        try
            Fs = 16000; % frecuencia muestreo
            recObj = audiorecorder(Fs,16,1);
            recordblocking(recObj,3);
            y = getaudiodata(recObj);
            audiowrite(archivoAudio,y,Fs);
            logConsola('🎙️ Audio grabado correctamente.');
        catch ME
            logConsola(['❌ Error al grabar audio: ' ME.message]);
            return;
        end

        % Ruta completa al script Python (AJUSTAR según tu carpeta)
        rutaPython = 'D:/Tareas USFX/2024/Ing. Electronica/ProyectoFinal Caida libre/matlab/reconocer_comando.py';

        % Ejecutar script Python para reconocimiento
        cmdPython = sprintf('python "%s" "%s"', rutaPython, archivoAudio);
        logConsola('🧠 Procesando comando con Python...');

        [status, cmdout] = system(cmdPython);

        if status ~= 0
            logConsola(['❌ Error en Python: ' cmdout]);
            return;
        end

        comando = lower(strtrim(cmdout));
        logConsola(['🔊 Comando detectado: ' comando]);

        % Interpretar comandos y enviar al Arduino
        switch comando
            case 'subir'
                logConsola('🔼 Ejecutando: Subir');
                writeline(s, 'subir');
            case 'bajar'
                logConsola('🔽 Ejecutando: Bajar');
                writeline(s, 'bajar');
            case 'activar'
                logConsola('✅ Ejecutando: Activar');
                writeline(s, 'activar');
            case 'desactivar'
                logConsola('❌ Ejecutando: Desactivar');
                writeline(s, 'desactivar');
            case 'iniciar'
                logConsola('▶️ Ejecutando: Iniciar');
                iniciarMedicion(); % Llama a tu función para iniciar medición
            otherwise
                logConsola('⚠️ Comando no reconocido. Comandos válidos: subir, bajar, activar, desactivar, iniciar');
        end
    end
function resultado = reconocimientoFacial()
    rutaPythonScript = 'D:\Tareas USFX\2024\Ing. Electronica\ProyectoFinal Caida libre\Matlab\reconocer_rostrov2.py';
    
    comando = sprintf('python "%s"', rutaPythonScript);
    [status, output] = system(comando);
    
    if status ~= 0
        error('Error ejecutando el script Python: %s', output);
    end
    
    outputLines = strsplit(output, newline);
    resultado = strtrim(outputLines{1});  % Primer línea del output
    
    % output = '1' o '0'
end

end