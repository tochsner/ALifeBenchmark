abstract type Logger end

struct DoNothingLogger <: Logger end

function log_step(logger::DoNothingLogger, model, save_genotype_as_file = true) end
function save_log(logger::DoNothingLogger) end
function log_birth(logger::DoNothingLogger, model, child, parent = nothing) end
function log_death(logger::DoNothingLogger, model, organism) end

should_terminate(snapshot) = should_terminate(get_logger(snapshot), snapshot)