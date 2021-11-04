using ALifeBenchmark
using Serialization
using Plots
using Measures

type = ARGS[1]

if "png" in ARGS
    file_format = "png"
else
    file_format = "svg"
end

if type == "simple_plot"
    data_file = ARGS[2]
    data = deserialize(data_file)

    x_axis_label = ARGS[3]
    y_axis_label = ARGS[4]

    times, values = data

    plot(times, values, 
            title = "",
            label = "",
            xguide = x_axis_label,
            yguide = y_axis_label,
            seriestype = :scatter,
            markersize = 1.5,
            markerstrokewidth = 0,
            size = (900, 600),
            margin = 10mm,
            dpi = 1000)
    
    savefig("$(data_file).$file_format")
end

if type == "2D"
    data_file = ARGS[2]
    data = deserialize(data_file)

    x_axis_label = ARGS[3]
    y_axis_label = ARGS[4]

    time_x, time_y, values = data

    if "remove_zeros" in ARGS
        # remove zeros
        time_x = [t for (i, t) in enumerate(time_x) if values[i] != 0]
        time_y = [t for (i, t) in enumerate(time_y) if values[i] != 0]
        values = [v for v in values if v != 0]
    elseif "replace_zero" in ARGS
        eps = parse(Float64, ARGS[end])
        values = [v == 0 ? eps : v for v in values]
    end

    plot(time_x, time_y,
        marker_z  = ("log" in ARGS) ? log10.(values) : values,
        title = "",
        label = "",
        xguide = x_axis_label,
        yguide = y_axis_label,
        seriestype = :scatter,
        markersize = ("small" in ARGS) ? 1.75 : 4,
        markerstrokewidth = 0,
        size = (900, 600),
        margin = 10mm,
        dpi = 1000)
    
    savefig("$(data_file).$file_format")
end

if type == "two_plots"
    if length(ARGS) == 5
        data_file_1, data_file_2 = ARGS[2], ARGS[3]
        x_axis_label = ARGS[4]
        y_axis_label = ARGS[5]
        
        data_1 = deserialize(data_file_1)
        data_2 = deserialize(data_file_2)

        times, values_1 = data_1
        _, values_2 = data_2
    else
        data_file = ARGS[2]
        x_axis_label = ARGS[3]
        y_axis_label = ARGS[4]
        
        data = deserialize(data_file)
        times, values_1, values_2 = data
    end

    plot(times, [values_1 values_2], 
    title = "",
    label = "",
    xguide = x_axis_label,
    yguide = y_axis_label,
    seriestype = :scatter,
    markersize = 1.5,
    markerstrokewidth = 0,
    size = (900, 600),
    margin = 10mm,
    dpi = 1000)
    
    if length(ARGS) == 5
        savefig("$(data_file_1) $(data_file_2).$file_format")
    else
        savefig("$(data_file).$file_format")
    end
end

if type == "two_log_plots"
    if length(ARGS) == 6
        data_file_1, data_file_2 = ARGS[2], ARGS[3]
        x_axis_label = ARGS[4]
        y_axis_label = ARGS[5]
        
        data_1 = deserialize(data_file_1)
        data_2 = deserialize(data_file_2)

        times, values_1 = data_1
        _, values_2 = data_2
    else
        data_file = ARGS[2]
        x_axis_label = ARGS[3]
        y_axis_label = ARGS[4]
        
        data = deserialize(data_file)
        times, values_1, values_2 = data
    end

    plot(times, [values_1 values_2], 
    title = "",
    label = "",
    xguide = x_axis_label,
    yguide = y_axis_label,
    xscale = :log10,
    seriestype = :scatter,
    markersize = 1.5,
    markerstrokewidth = 0,
    size = ("half" in ARGS) ? (450, 300) : (900, 600),
    margin = 10mm,
    dpi = 1000)
    
    if length(ARGS) == 6
        savefig("$(data_file_1) $(data_file_2).$file_format")
    else
        savefig("$(data_file).$file_format")
    end
end