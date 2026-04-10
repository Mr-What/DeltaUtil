% load tilted_delta from a klipper printer.cfg file
function p = loadTiltedCfg(fNam)
    p.fileName = fNam;
    p.position_endstops = [500,500,500];  % pre-allocate stuff from stepper_.
    p.rotation_distances = [40,40,40];
    fid = fopen (fNam, "r");
    if (fid < 0)
        error ("could not open %s", fNam);
        return;
    end

    section = "none";
    while (true)
        line0 = fgetl(fid);       % read one line as a string, no trailing newline
        if (line0 == -1)
            break;                  % EOF
        end
        line = strtrim(regexprep(line0, '#.*$', ''));
        if !isempty(regexp(line,'^\[.+\]$', 'once'))
            section = line(2:length(line)-1)
            continue;
        end

        if strncmp(section,'stepper_',8)
            idx = int32(section(9)) - int32('a') + int32(1);
            val = parseConfigValue('rotation_distance', line);
            if numel(val) > 0
                p.rotation_distances(idx) = val;
                continue;
            end
            val = parseConfigValue('position_endstop', line);
            if numel(val) > 0
                p.position_endstops(idx) = val;
                continue;
            end
        end

        if strncmp(section,'printer',7)
            val = parseConfigValue('delta_radius', line);
            if numel(val) > 0
                p.delta_radius = val;
                continue;
            end
            val = parseConfigValue('delta_angles', line);
            if numel(val) > 0
                p.delta_angles = val;
                continue;
            end
            val = parseConfigValue('arm_lengths', line);
            if numel(val) > 0
                p.arm_lengths = val;
                continue;
            end
            val = parseConfigValue('tilt_radial', line);
            if numel(val) > 0
                p.tilt_radial = val;
                continue;
            end
            val = parseConfigValue('tilt_tangential', line);
            if numel(val) > 0
                p.tilt_tangential = val;
                continue;
            end
        end
    end

    fclose (fid);
end

function val = parseConfigValue(nam, line)
    re = ['^',nam,'\s*:'];
    val = [];
    if isempty(regexp(line,re, 'once'))
        return;
    end
    val = strtrim(regexprep(line, '^.+:', ''));
    vals = strsplit(val, '[\s*,\s*]', 'delimitertype','regularexpression');
    fprintf(1,'\t%s \t',nam);
    val = str2double(vals);
    disp(val);
end

