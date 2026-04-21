<?php
/**
 * Input Validator Helper
 */

class Validator {
    private $errors = [];
    private $data = [];
    
    public function __construct($data) {
        $this->data = $data;
    }
    
    public function required($field, $message = null) {
        if (!isset($this->data[$field]) || trim($this->data[$field]) === '') {
            $this->errors[$field] = $message ?? "$field is required";
        }
        return $this;
    }
    
    public function email($field, $message = null) {
        if (isset($this->data[$field]) && !filter_var($this->data[$field], FILTER_VALIDATE_EMAIL)) {
            $this->errors[$field] = $message ?? "Invalid email format";
        }
        return $this;
    }
    
    public function phone($field, $message = null) {
        if (isset($this->data[$field])) {
            $phone = preg_replace('/[^0-9+]/', '', $this->data[$field]);
            if (strlen($phone) < 9 || strlen($phone) > 15) {
                $this->errors[$field] = $message ?? "Invalid phone number";
            }
        }
        return $this;
    }
    
    public function minLength($field, $min, $message = null) {
        if (isset($this->data[$field]) && strlen($this->data[$field]) < $min) {
            $this->errors[$field] = $message ?? "$field must be at least $min characters";
        }
        return $this;
    }
    
    public function maxLength($field, $max, $message = null) {
        if (isset($this->data[$field]) && strlen($this->data[$field]) > $max) {
            $this->errors[$field] = $message ?? "$field must not exceed $max characters";
        }
        return $this;
    }
    
    public function in($field, $values, $message = null) {
        if (isset($this->data[$field]) && !in_array($this->data[$field], $values)) {
            $this->errors[$field] = $message ?? "$field must be one of: " . implode(', ', $values);
        }
        return $this;
    }
    
    public function numeric($field, $message = null) {
        if (isset($this->data[$field]) && !is_numeric($this->data[$field])) {
            $this->errors[$field] = $message ?? "$field must be numeric";
        }
        return $this;
    }
    
    public function min($field, $min, $message = null) {
        if (isset($this->data[$field]) && is_numeric($this->data[$field]) && $this->data[$field] < $min) {
            $this->errors[$field] = $message ?? "$field must be at least $min";
        }
        return $this;
    }
    
    public function max($field, $max, $message = null) {
        if (isset($this->data[$field]) && is_numeric($this->data[$field]) && $this->data[$field] > $max) {
            $this->errors[$field] = $message ?? "$field must not exceed $max";
        }
        return $this;
    }
    
    public function match($field, $matchField, $message = null) {
        if (isset($this->data[$field]) && isset($this->data[$matchField])) {
            if ($this->data[$field] !== $this->data[$matchField]) {
                $this->errors[$field] = $message ?? "$field does not match $matchField";
            }
        }
        return $this;
    }
    
    public function unique($field, $table, $column = null, $exceptId = null, $message = null) {
        $column = $column ?? $field;
        if (isset($this->data[$field])) {
            $db = Database::getInstance();
            $sql = "SELECT id FROM $table WHERE $column = ?";
            $params = [$this->data[$field]];
            
            if ($exceptId) {
                $sql .= " AND id != ?";
                $params[] = $exceptId;
            }
            
            $result = $db->fetch($sql, $params);
            if ($result) {
                $this->errors[$field] = $message ?? "$field already exists";
            }
        }
        return $this;
    }
    
    public function isValid() {
        return empty($this->errors);
    }
    
    public function getErrors() {
        return $this->errors;
    }
    
    public function validate() {
        if (!$this->isValid()) {
            Response::validationError($this->errors);
        }
        return true;
    }
}
