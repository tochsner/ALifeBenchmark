abstract type Logger end

struct DoNothingLogger <: Logger end

function log_step(logger::DoNothingLogger, model) end
function save_log(logger::DoNothingLogger) end
function log_birth(logger::DoNothingLogger, model, child, parent=nothing) end
function log_death(logger::DoNothingLogger, model, organism) end
