
with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;

-- NO ACTIVAR ESTE PAQUETE MIENTRAS NO SE TENGA PROGRAMADA LA INTERRUPCION
-- Packages needed to generate button interrupts       
-- with Ada.Interrupts.Names;
-- with Button_Interrupt; use Button_Interrupt;

package body fss is 

    ----------------------------------------------------------------------
    ------------- procedure exported 
    ----------------------------------------------------------------------
    procedure Background is
    begin
      loop
        null;
      end loop;
    end Background;
    ----------------------------------------------------------------------

    -----------------------------------------------------------------------
    ------------- declaration of protected objects 
    -----------------------------------------------------------------------

    -- Aqui se declaran los objetos protegidos para los datos compartidos  


    -----------------------------------------------------------------------
    ------------- declaration of tasks 
    -----------------------------------------------------------------------

    task Prueba_Velocidad_Distancia is
      pragma Priority (5);
    end Prueba_Velocidad_Distancia;

    task Prueba_Altitud_Joystick is
      pragma Priority (5);
    end Prueba_Altitud_Joystick;

    task Prueba_Sensores_Piloto is
      pragma Priority (5);
    end Prueba_Sensores_Piloto;

    task Pitch_Roll is 
      pragma Priority(5);
    end Pitch_Roll;

    task Altitude is
      pragma Priority(5);
    end Altitude;


    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------
    task body Prueba_Velocidad_Distancia is
      Current_Pw: Power_Samples_Type := 0;
      Current_S: Speed_Samples_Type := 500; 
      Calculated_S: Speed_Samples_type := 0; 
            
      Current_D: Distance_Samples_Type := 0;
      Current_L: Light_Samples_Type := 0;
      Aircraft_Roll: Roll_Samples_Type;

      ----ajustes del delay
      Siguiente_instance : Time;
      Intervalo : Time_Span := Milliseconds(300);
              
      begin
        Siguiente_instance := Clock + Intervalo;
        loop     
          Start_Activity ("Prueba_Velocidad");        
                   
          -- Prueba potencia del piloto 
          Read_Power (Current_Pw);  -- lee la potencia de motor indicada por el piloto
          Display_Pilot_Power (Current_Pw);
                    
          -- transfiere la potencia/velocidad a la aeronave
          Calculated_S := Speed_Samples_type (float (Current_Pw) * 1.2); -- aplicar fórmula
          
          if (Calculated_S < 1000) then 
            Set_Speed (Calculated_S);
            Light_1 (Off);
          elsif (Calculated_S > 1000) then
            Light_1 (On);
            Calculated_S := Speed_Samples_type (1000);
            Set_Speed (Calculated_S);
          end if;
          
          -- Comprueba la velocidad real de la aeronave
          Current_S := Read_Speed;        -- lee la velocidad actual de la aeronave
          Display_Speed (Current_S);

          -- Prueba distancia con obstaculos
          Read_Distance (Current_D);
          if(Current_D < 2000) then
            Alarm (4);
          elsif (Current_D < 4000) then
            Alarm (2);
          end if;

          if(Current_D < 1000) then
            Set_Aircraft_Roll (40);
            Aircraft_Roll := Read_Roll;
            Display_Roll (Aircraft_Roll);
          end if;
          

          Display_Distance (Current_D);
        
                                
        Finish_Activity ("Prueba_Velocidad");   
        delay until (Siguiente_instance);
        Siguiente_instance := Siguiente_instance + Intervalo;

        end loop;

    end Prueba_Velocidad_Distancia;


    task body Prueba_Altitud_Joystick is
      Current_J: Joystick_Samples_Type := (0,0);
      Target_Pitch: Pitch_Samples_Type := 0;
      Target_Roll: Roll_Samples_Type := 0; 
      Aircraft_Pitch: Pitch_Samples_Type; 
      Aircraft_Roll: Roll_Samples_Type;
      
      Current_A: Altitude_Samples_Type := 8000;

      ----ajustes del delay
      Siguiente_instance : Time;
      Intervalo : Time_Span := Milliseconds(300);
        
    begin
      Siguiente_instance := Clock + Intervalo;
      loop     
        Start_Activity ("Prueba_Altitud");
        
        -- Lee Joystick del piloto
        Read_Joystick (Current_J);
        
        -- establece Pitch y Roll en la aeronave
        Target_Pitch := Pitch_Samples_Type (Current_J(x));
        Target_Roll := Roll_Samples_Type (Current_J(y));

        if(Target_Pitch > 30) then
          Set_Aircraft_Pitch (Pitch_Samples_Type (30));  -- transfiere el movimiento pitch a la aeronave
        elsif (Target_Pitch < -30) then
          Set_Aircraft_Pitch (Pitch_Samples_Type (-30));
        else
          Set_Aircraft_Pitch(Target_Pitch);
        end if;


        if(Target_Roll > 45) then
          Set_Aircraft_Roll (Roll_Samples_Type (45));    -- transfiere el movimiento roll  a la aeronave
        elsif (Target_Roll < -45) then
          Set_Aircraft_Roll (Roll_Samples_Type (-45));
        else
          Set_Aircraft_Roll(Target_Roll);
        end if; 

                    
        Aircraft_Pitch := Read_Pitch;       -- lee la posición pitch de la aeronave
        Aircraft_Roll := Read_Roll;         -- lee la posición roll  de la aeronave
        
        Display_Joystick (Current_J);       -- muestra por display el joystick  
        Display_Pitch (Aircraft_Pitch);     -- muestra por display la posición de la aeronave  
        Display_Roll (Aircraft_Roll);

        -- Comprueba altitud
        Current_A := Read_Altitude;         -- lee y muestra por display la altitud de la aeronave  
        Display_Altitude (Current_A);
        
        if(Current_A > 10000) then
          Light_2 (On);
        elsif (Current_A > 9000) then
          Alarm (3); 
          Display_Message ("To high");
        end if;

            
        Finish_Activity ("Prueba_Altitud");                      
        delay until (Siguiente_instance);
        Siguiente_instance := Siguiente_instance + Intervalo;
      end loop;

      

    end Prueba_Altitud_Joystick;


    task body Prueba_Sensores_Piloto is
      Current_Pp: PilotPresence_Samples_Type := 1;
      Current_Pb: PilotButton_Samples_Type := 0;

      ----ajustes del delay
      Siguiente_instance : Time;
      Intervalo : Time_Span := Milliseconds(300);

    begin
      Siguiente_instance := Clock + Intervalo;
      loop
        Start_Activity ("Prueba_Piloto");                
        -- Prueba presencia piloto
        Current_Pp := Read_PilotPresence;
        if (Current_Pp = 0) then Alarm (1); end if;   
        Display_Pilot_Presence (Current_Pp);
              
        -- Prueba botón para selección de modo 
        Current_Pb := Read_PilotButton;            
        Display_Pilot_Button (Current_Pb); 
        
        Finish_Activity ("Prueba_Piloto");  
        delay until (Siguiente_instance);
        Siguiente_instance := Siguiente_instance + Intervalo;
      end loop;

      

    end Prueba_Sensores_Piloto;


------------------------------------------------------------------------------------------------------------------------------------------
    task body Pitch_Roll is
      Current_J: Joystick_Samples_Type := (0,0);
      Target_Pitch: Pitch_Samples_Type := 0;
      Target_Roll: Roll_Samples_Type := 0; 
      Aircraft_Pitch: Pitch_Samples_Type; 
      Aircraft_Roll: Roll_Samples_Type;
      
      Current_A: Altitude_Samples_Type := 8000;

      ----ajustes del delay
      Siguiente_instance : Time;
      Intervalo : Time_Span := Milliseconds(200);
    begin
      -- 2.k 
      Siguiente_instance := Clock + Intervalo;
         loop     
            Start_Activity ("Pitch_Roll");
            
            -- Lee Joystick del piloto
            Read_Joystick (Current_J);
            
            -- establece Pitch y Roll en la aeronave

            -- 1.g
            if ((Current_J(x) < -3) or (Current_J(x) > 3)) then
               Target_Pitch := Pitch_Samples_Type (Current_J(x));
            end if;

            if ((Current_J(y) < -3) or (Current_J(y) > 3)) then
               Target_Roll := Roll_Samples_Type (Current_J(y));
            end if;


            -- 1.h y 2.d
            if(Target_Pitch > 30) then
               Set_Aircraft_Pitch (Pitch_Samples_Type (30));  -- transfiere el movimiento pitch a la aeronave
            elsif (Target_Pitch < -30) then
               Set_Aircraft_Pitch (Pitch_Samples_Type (-30));
            else
               Set_Aircraft_Pitch(Target_Pitch);
            end if;

            --3.e
            if(Target_Roll > 35) then 
               Display_Message("Alabeo en zona critica");
            elsif (Target_Roll < -35) then
               Display_Message("Alabeo en zona critica")

            -- 1.h
            if(Target_Roll > 45) then
               Set_Aircraft_Roll (Roll_Samples_Type (45));    -- transfiere el movimiento roll  a la aeronave
            elsif (Target_Roll < -45) then
               Set_Aircraft_Roll (Roll_Samples_Type (-45));
            else
               Set_Aircraft_Roll(Target_Roll);
            end if; 

                        
            Aircraft_Pitch := Read_Pitch;       -- lee la posición pitch de la aeronave
            Aircraft_Roll := Read_Roll;         -- lee la posición roll  de la aeronave
            
            Display_Joystick (Current_J);       -- muestra por display el joystick  
            Display_Pitch (Aircraft_Pitch);     -- muestra por display la posición de la aeronave  
            Display_Roll (Aircraft_Roll);

            -- Comprueba altitud
            Current_A := Read_Altitude;         -- lee y muestra por display la altitud de la aeronave  
            Display_Altitude (Current_A);
            
            if(Current_A > 10000) then
               Light_2 (On);
            elsif (Current_A > 9000) then
               Alarm (3); 
               Display_Message ("To high");
            end if;

                  
            Finish_Activity ("Pitch_Roll");                      
            delay until (Siguiente_instance);
            Siguiente_instance := Siguiente_instance + Intervalo;
         end loop;


    end Pitch_Roll;


   task body Altitude is
      begin
   end Altitude;
    


    ----------------------------------------------------------------------
    ------------- procedimientos para probar los dispositivos 
    ------------- SE DEBERÁN QUITAR PARA EL PROYECTO
    ----------------------------------------------------------------------
    

begin
   Start_Activity ("Programa Principal");
   --Prueba_Velocidad_Distancia;
   --Prueba_Altitud_Joystick;
   --Prueba_Sensores_Piloto;
   Finish_Activity ("Programa Principal");
end fss;



