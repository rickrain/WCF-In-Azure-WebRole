using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

namespace Calculator.WCF.Library
{
    public class Calculator : ICalculator
    {
        public double Add(double n1, double n2)
        {
            return n1 + n2;
        }

        public double Subtract(double n1, double n2)
        {
            return n1 - n2;
        }

        public double Multiply(double n1, double n2)
        {
            return n1 * n2;
        }

        public double Divide(double n1, double n2)
        {
            return n1 / n2;
        }
    }
}
