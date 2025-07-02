nombre = inputdlg('Ingrese su nombre:','Registro de rostro',1);
if isempty(nombre)
    disp("❌ Cancelado.");
    return;
end
nombre = nombre{1};

comando = sprintf('python "%s" "%s"', ...
    '\registrar_rostro.py', ...
    nombre);

disp("📤 Registrando rostro...");
[status, output] = system(comando);
disp(output);

if contains(output, "registrado correctamente")
    msgbox("✅ Rostro registrado correctamente");
else
    msgbox("❌ Ocurrió un error durante el registro");
end
