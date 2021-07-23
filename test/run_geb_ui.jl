using Gtk, Graphics
using ALifeBenchmark
import Random
using Profile
using Serialization

model = deserialize("geb_logs/snapshots/778557744733939_842507053402753") # GebModel(size=20)

c = @GtkCanvas()
win = GtkWindow(c, "Geb", 1000, 800)
showall(win)

function paint(ctx, h, w, model::GebModel)
    set_source_rgb(ctx, 0.5, 0.5, 0.5)
    
    for i in 1:(model.size-1)
        move_to(ctx, 0, h/model.size * i)
        line_to(ctx, w, h/model.size * i)
    end
    for i in 1:(model.size-1)
        move_to(ctx, w/model.size * i, 0)
        line_to(ctx, w/model.size * i, h)
    end
    stroke(ctx)

    for organism in model.organisms
        paint(ctx, h, w, organism)
    end
end

function paint(ctx, h, w, organism::GebOrganism)
    x, y = organism.coordinates

    x, y = x / model.size, y / model.size
    x, y = x*w, y*h

    set_source_rgb(ctx, 0, 0, min(1.0, organism.age / 10))

    circle(ctx, x, y, 3)
    fill(ctx)
    
    move_to(ctx, x, y)
    line_to(ctx, x + 10*cosd(organism.direction), y + 10*sind(organism.direction))
    stroke(ctx)
end

function paint()
    @guarded draw(c) do widget
        ctx = getgc(c)
        h = height(c)
        w = width(c)

        rectangle(ctx, 0, 0, w, h)
        set_source_rgb(ctx, 1, 1, 1)
        fill(ctx)

        paint(ctx, h, w, model)
    end
    show(c)
end

function run(m, n)
    Random.seed!(105)

    n_epochs = 0

    for _ in 1:m
        @time for _ in 1:n
            execute!(model)
            n_epochs += 1

            if n_epochs % 500 == 0
                println(n_epochs)
            end
        end

        println(model)        


        for _ in 1:200
            execute!(model) 
            paint()
            sleep(0.1)
            n_epochs += 1   
        end
    end
end

run(100, 0)