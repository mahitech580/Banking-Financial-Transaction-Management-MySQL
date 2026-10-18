-- Deterministic utility functions for illustrative SQL calculations.
USE banking_financial_management;

DROP FUNCTION IF EXISTS calculate_risk_band;
DROP FUNCTION IF EXISTS calculate_emi;

DELIMITER $$

CREATE FUNCTION calculate_risk_band(p_score DECIMAL(5,2))
RETURNS VARCHAR(12)
DETERMINISTIC
NO SQL
BEGIN
  IF p_score IS NULL OR p_score < 0 OR p_score > 100 THEN
    RETURN 'INVALID';
  END IF;

  RETURN CASE
    WHEN p_score >= 80 THEN 'HIGH'
    WHEN p_score >= 50 THEN 'MEDIUM'
    ELSE 'LOW'
  END;
END$$

CREATE FUNCTION calculate_emi(
  p_principal DECIMAL(18,2),
  p_annual_rate_pct DECIMAL(6,3),
  p_tenure_months INT
)
RETURNS DECIMAL(18,2)
DETERMINISTIC
NO SQL
BEGIN
  DECLARE v_monthly_rate DECIMAL(12,10);

  IF p_principal IS NULL OR p_principal <= 0
     OR p_annual_rate_pct IS NULL OR p_annual_rate_pct < 0
     OR p_tenure_months IS NULL OR p_tenure_months <= 0 THEN
    RETURN NULL;
  END IF;

  IF p_annual_rate_pct = 0 THEN
    RETURN ROUND(p_principal / p_tenure_months, 2);
  END IF;

  SET v_monthly_rate = (p_annual_rate_pct / 100) / 12;
  RETURN ROUND(
    p_principal * v_monthly_rate * POW(1 + v_monthly_rate, p_tenure_months)
    / (POW(1 + v_monthly_rate, p_tenure_months) - 1),
    2
  );
END$$

DELIMITER ;

-- Examples:
-- SELECT calculate_risk_band(88.50);
-- SELECT calculate_emi(300000.00, 8.250, 48);


-- Boundary values demonstrate the declared score bands.
SELECT calculate_risk_band(0.00) AS zero_score,calculate_risk_band(49.99) AS low_upper_edge,calculate_risk_band(50.00) AS medium_lower_edge,calculate_risk_band(79.99) AS medium_upper_edge,calculate_risk_band(80.00) AS high_lower_edge,calculate_risk_band(100.00) AS maximum_score;


-- Invalid inputs are explicitly mapped to INVALID by the example utility.
SELECT calculate_risk_band(-1.00) AS negative_score,calculate_risk_band(100.01) AS score_above_max,calculate_risk_band(NULL) AS missing_score;
