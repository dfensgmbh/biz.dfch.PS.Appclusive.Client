using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using biz.dfch.CS.Appclusive.Public.Configuration;
using biz.dfch.CS.Appclusive.Public.Converters;

namespace biz.dfch.Appclusive.Products.Tests.Mock
{
    public class SimpleProductOne : EntityBagBaseDto
    {
        [EntityBag("biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne.Name")]
        [EntityBagDescription("This string property specifies the displayname of the virtual machine.")]
        [DefaultValue("SimpleProductOne")]
        [Required]
        public virtual string Name { get; set; }

        [EntityBag("biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne.CpuSpeed")]
        [EntityBagDescription("This floating point property specifies the cpu speed of the virtual machine.")]
        [Range(0.25, 2.50)]
        [DefaultValue(0.5)]
        [Increment(.1)]
        [Unit("GHz")]
        [Required]
        public virtual double CpuSpeed { get; set; }

        [EntityBag("biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne.MemoryReserverationPercent")]
        [Range(0.0, 1)]
        [Increment(0.01)]
        [Unit("%")]
        [EntityBagDescription("This number property specifies the percentage of memory to be reserved of the virtual machine.")]
        [DefaultValue(1)]
        [Required]
        public virtual int MemoryReserverationPercent { get; set; }
    }
}
