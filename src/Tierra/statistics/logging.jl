import Serialization

function log_model(model::TierraModel)
    if LOG_PROBABILITY < rand() return end

    serialize(model, SNAPSHOTS_FOLDER + str(model.time))
end