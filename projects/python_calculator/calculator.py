class Calculator:
  def add(self, x, y): return x + y
        # Simulating an insecure method prone to command injection
        import os
        result = os.system(f"echo {x} + {y}")  # Vulnerability: Command injection
        return result