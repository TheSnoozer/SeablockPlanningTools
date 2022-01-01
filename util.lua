SeablockPlanningTools.math = {}

function SeablockPlanningTools.math.dotp(v1, v2)
  return v1.x * v2.x + v1.y * v2.y
end

function SeablockPlanningTools.math.mag(v)
  return math.sqrt(math.pow(math.abs(v.x), 2) + math.pow(math.abs(v.y), 2))
end

function SeablockPlanningTools.math.vector_from(start_pos, end_pos)
  return { x = end_pos.x - start_pos.x, y = end_pos.y - start_pos.y }
end

function SeablockPlanningTools.math.unit_vector(v)
  local v_mag = SeablockPlanningTools.math.mag(v)
  return { x = v.x / v_mag, y = v.y / v_mag }
end